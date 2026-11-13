const fs=require('fs'),vm=require('vm'),assert=require('node:assert/strict');
const html=fs.readFileSync('index.html','utf8');
for(const m of html.matchAll(/<script>([\s\S]*?)<\/script>/g))new Function(m[1]);
const read=html.slice(html.indexOf('async function readProfiles('),html.indexOf('function careTags('));
(async()=>{
for(const scenario of ['new','missing','denied']){
 const calls=[];const ctx=vm.createContext({extendedProfiles:true,baseProfileFields:'user_id',extraProfileFields:',pet_types',api:{from:()=>({select:fields=>{calls.push(fields);let result=fields.includes('pet_types')&&scenario!=='new'?{error:{code:scenario==='missing'?'42703':'42501'}}:{data:{display_name:'Alex'}};return{eq:()=>({maybeSingle:async()=>result}),order:()=>({limit:async()=>result})};}})}});
 vm.runInContext(read,ctx);const result=await ctx.readProfiles('owner');assert.equal(calls.length,scenario==='missing'?2:1);assert.equal(!!result.error,scenario==='denied');assert.equal(ctx.extendedProfiles,scenario!=='missing');
}
const save=html.slice(html.indexOf('sitterForm.onsubmit=async e=>{'),html.indexOf('async function loadSitters(){'));
for(const [extended,years,fail] of [[true,'0',false],[true,'',false],[false,'',false],[true,'4',true]]){
 let stored=null,closed=false;const btn={disabled:false};const fields={display_name:' Alex ',suburb:'Mount Eden',service:'Pet sitting',rate_nzd:'35',bio:' Loving care for pets. ',experience_years:years};
 const ctx=vm.createContext({sitterForm:{querySelector:()=>btn,elements:{namedItem:()=>({files:[]})}},user:{id:'owner'},sitterMessage:{textContent:''},extendedProfiles:extended,FormData:class{entries(){return Object.entries(fields)}getAll(n){return n==='pet_types'?['Dogs','Cats']:['1','7']}},api:{from:()=>({upsert:async(p)=>{if(fail)throw Error('offline');stored=p;return {}}})},sitterDialog:{close:()=>{closed=true}},loadSitters:async()=>{}});
 vm.runInContext(save,ctx);await ctx.sitterForm.onsubmit({preventDefault(){}});assert.equal(btn.disabled,false);assert.equal(closed,!fail);
 if(fail){assert.match(ctx.sitterMessage.textContent,/Could not save/);continue;}
 assert.equal(stored.user_id,'owner');assert.equal(stored.display_name,'Alex');
 if(extended){assert.equal(stored.experience_years,years===''?null:Number(years));assert.equal(JSON.stringify(stored.available_days),'[1,7]');assert.equal(JSON.stringify(stored.pet_types),'["Dogs","Cats"]');}else assert.equal('pet_types' in stored,false);
}
console.log('PASS: script syntax; new schema; missing-column retry; authorization error preserved; profile save payload; zero and blank experience; legacy save; network failure re-enables save.');
})();
