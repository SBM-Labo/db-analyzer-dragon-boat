const {chromium}=require('playwright');
const fs=require('fs');
(async()=>{const b=await chromium.launch();const p=await b.newPage({viewport:{width:1200,height:800}});
const errs=[];p.on('pageerror',e=>errs.push('PE '+e.message));
await p.goto('http://localhost:8765/_test.html'); await p.waitForTimeout(3000);
const m=JSON.parse(fs.readFileSync('manifest.json','utf8'));
const out=[];
for(const ev of m.events){ for(const r of ev.races){
  const o=await p.evaluate(async ({file,team})=>{
    state.races.length=0;
    await loadSampleByUrl(file, team, true);
    const r=state.races[state.races.length-1]; if(!r) return null;
    const an=getAn(r); const off=lookupOfficialTime(r); const meta=extractMeta(r);
    const R=x=>x==null||!isFinite(x)?null:Math.round(x*1000)/1000;
    const o={file, e:meta.eventId, rno:meta.raceNo, cls:meta.klass, team, off:off&&off.time_sec||null, rank:off&&off.rank||null, acc:!!(an&&an.acc)};
    if(an){ o.peakV=R(an.peak.v); o.peakD=R(an.peak.d); o.peakN=R(an.peak.strokes); o.peakT=R(an.peak.t);
      o.seg=an.segs.map(s=>R(s.time)); o.segSr=an.segs.map(s=>R(s.sr)); o.segDps=an.segs.map(s=>R(s.dps));
      if(an.cruise){o.cSr=R(an.cruise.sr);o.cDps=R(an.cruise.dps);o.cV=R(an.cruise.v);}
      o.last=R(an.lastRatio); o.srPeak=R(an.srPeak); o.srLast=R(an.srLast); o.cv=an.stability?R(an.stability.cv):null;
      if(an.shift){o.shT=R(an.shift.t);o.shD=R(an.shift.d);o.shN=an.shift.n;}
      o.tFin=R(an.tFinish); o.strokes=R(an.totalStrokes);
    }
    state.races.length=0; return o;
  },{file:r.file,team:r.team});
  if(o) out.push(o); process.stdout.write('.');
}}
fs.writeFileSync('bench_raw.json',JSON.stringify(out));
console.log('\n',out.length, errs.slice(0,5).join('\n')||'no errors');await b.close()})();
