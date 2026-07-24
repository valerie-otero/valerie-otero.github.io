// exécute le script de la page avec le stub, puis sérialise #svgR en SVG autonome
const fs=require('fs');
const sc=process.env.SC;
const stub=fs.readFileSync(sc+'/domstub.js','utf8').replace(/try\{[\s\S]*$/,'');
eval(stub);
require(sc+'/page_script.js');
const esc=s=>String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
function ser(e){
  if(!e.tag)return'';
  const at=Object.entries(e.attrs).map(([k,v])=>` ${k}="${esc(v)}"`).join('');
  const kids=e.children.map(ser).join('');
  const txt=e.textContent?esc(e.textContent):'';
  return `<${e.tag}${at}>${txt}${kids}</${e.tag}>`;
}
const svg=document.getElementById(process.env.FACE||'svgR');
const coff=parseFloat(process.env.COFF||'0');
(function mark(e){if(!e||!e.tag)return;
  if((e.attrs['class']||'').split(' ').includes('cou-part'))e.attrs['transform']=`translate(${coff} 0)`;
  e.children.forEach(mark);})(svg);
const body=svg.children.map(ser).join('\n');
fs.writeFileSync(sc+'/recto.svg',
`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1180 430" width="2360" height="860" font-family="Helvetica, Arial, sans-serif">
<rect width="1180" height="430" fill="#efe7d2"/>
${body}
</svg>`);
console.log('written, children:',svg.children.length);
