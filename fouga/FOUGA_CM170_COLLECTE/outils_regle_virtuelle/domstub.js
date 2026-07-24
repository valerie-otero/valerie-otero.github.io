// mini-stub DOM pour exécuter le script de la page et attraper les erreurs runtime
const attrsOf=e=>e.attrs;
function mkEl(tag){
  const _cl=new Set();
  const e={tag,attrs:{},children:[],style:{},classList:{add(c){_cl.add(c);},remove(c){_cl.delete(c);},toggle(c,f){f?_cl.add(c):_cl.delete(c);},contains:c=>_cl.has(c)},
    setAttribute(k,v){e.attrs[k]=String(v);},getAttribute(k){return e.attrs[k]??null;},
    appendChild(c){e.children.push(c);return c;},
    addEventListener(){},removeEventListener(){},
    querySelectorAll:()=>[],querySelector:()=>null,
    getBoundingClientRect:()=>({left:0,top:0,width:1180,height:300}),
    setPointerCapture(){},focus(){},
    textContent:"",innerHTML:"",value:"",dataset:{},
  };
  return e;
}
const registry={};
const ids=["svgR","svgV","hint","r-table","v-montee","coulisse","vp-cursor","vp-out","noteVP",
 "i-v","i-t","i-d","w-ang","w-force","w-vp","w-eff","w-drift","w-head","w-note","lvlSeg",
 "d-alt","d-out","m-out","mode-note"];
global.document={
  _els:registry,
  createElementNS:(ns,tag)=>mkEl(tag),
  createElement:tag=>mkEl(tag),
  getElementById(id){
    if(!registry[id]){registry[id]=mkEl("div");registry[id].attrs.id=id;}
    return registry[id];
  },
  querySelectorAll:()=>[],querySelector:()=>null,
  addEventListener(){},
};
global.window={addEventListener(){},matchMedia:()=>({matches:false,addEventListener(){}})};
global.navigator={};
global.document.body={nodeType:1,tagName:"BODY",firstChild:null,namespaceURI:null};
// piège : certains g créés par le script reçoivent id via setAttribute → getElementById doit les retrouver
const origNS=global.document.createElementNS;
global.document.createElementNS=(ns,tag)=>{
  const e=mkEl(tag);
  const orig=e.setAttribute;
  e.setAttribute=(k,v)=>{orig(k,v);if(k==="id")registry[v]=e;};
  return e;
};
try{
  require(process.argv[2]);
  console.log("RUNTIME OK");
}catch(err){
  console.log("RUNTIME ERROR:", err.message);
  console.log(err.stack.split("\n").slice(0,6).join("\n"));
  process.exit(1);
}
