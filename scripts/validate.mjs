import { readFile, readdir, stat } from 'node:fs/promises';
import { extname, join, relative, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const docs = join(root, 'docs');
const errors = [];

async function filesIn(directory) {
  const entries = await readdir(directory);
  const files = [];
  for (const entry of entries) {
    const path = join(directory, entry);
    const info = await stat(path);
    files.push(...(info.isDirectory() ? await filesIn(path) : [path]));
  }
  return files;
}

function localTarget(rawTarget) {
  const target = rawTarget.trim().replace(/^<|>$/g, '');
  if (!target || target.startsWith('#') || /^(?:[a-z]+:|\/\/)/i.test(target)) return null;
  return decodeURIComponent(target.split(/[?#]/, 1)[0]);
}

for (const file of await filesIn(docs)) {
  if (extname(file) !== '.md') continue;
  const source = (await readFile(file, 'utf8')).replace(/<!--[\s\S]*?-->/g, '');
  const linkPattern = /!?(?:\[[^\]]*\])\(([^)]+)\)/g;
  for (const match of source.matchAll(linkPattern)) {
    const target = localTarget(match[1]);
    if (!target) continue;
    const normalized = target.replace(/^\//, '');
    const bases = file.endsWith('_sidebar.md') || target.startsWith('/')
      ? [docs]
      : [resolve(file, '..'), docs];
    const candidates = bases.flatMap((base) => {
      const destination = resolve(base, normalized);
      return extname(destination) ? [destination] : [destination, `${destination}.md`];
    });
    const found = (await Promise.all(candidates.map(async (candidate) => {
      try {
        await stat(candidate);
        return true;
      } catch {
        return false;
      }
    }))).some(Boolean);
    if (!found) {
      errors.push(`${relative(root, file)} -> ${match[1]}`);
    }
  }
}

const html = await readFile(join(docs, 'index.html'), 'utf8');
for (const required of [
  '<html lang="zh-CN">',
  'loadSidebar: true',
  'plugins:',
  'docsify@5.0.0',
]) {
  if (!html.includes(required)) errors.push(`docs/index.html 缺少必要配置：${required}`);
}

const configScript = html.match(/<script>\s*(window\.\$docsify[\s\S]*?)<\/script>/)?.[1];
if (!configScript) {
  errors.push('docs/index.html 中未找到 Docsify 配置脚本');
} else {
  try {
    new Function('window', configScript)({});
  } catch (error) {
    errors.push(`docs/index.html 配置脚本语法错误：${error.message}`);
  }
}

if (errors.length) {
  console.error(`校验失败（${errors.length} 项）：\n${errors.map((item) => `- ${item}`).join('\n')}`);
  process.exitCode = 1;
} else {
  console.log('校验通过：内部链接与 Docsify 配置均有效。');
}
