s.boot;

(

fork{
SynthDef(\buff, {|freq = 10, dur = 10, gate = 1, buff, rate = 1, pos = 0, pan = 0, out = 0, spr|
    var trig = Impulse.ar(freq);
    var spread = TRand.ar((-1) * spr * 0.5, spr * 0.5, trig);
    var sig = GrainBuf.ar(2, trig, dur, buff, rate, pos + spread + spr, 0, pan);
        var env = EnvGen.kr(Env([0.0, 1, 1, 0], [Rand(0.05, 0.8), Rand(0.1, 0.4), Rand(0.01, 0.5)]), doneAction: 2);
    Out.ar(out, sig * env * 0.02 );
}).add;

SynthDef(\rev, {|out, in|
    var sig = In.ar(in, 2);
    sig = FreeVerb.ar(Limiter.ar(sig), 0.1, 0.5, 0.1);
    Out.ar(0, sig);
    }
).add;

~rev = Bus.audio(s, 2);
s.sync;
Synth(\rev, [\in: ~rev]);

~synths = Dictionary.new;


~buffers =  "pathFolder/*".pathMatch.collect({|file| Buffer.readChannel(s, file, channels:0)});

~total = 0;

OSCdef(\makesynth, {|msg|
    //msg.postln;
    if(~total < 60, {
        x = Synth(\buff, [\freq: rrand(0.1, 40), \dur: rrand(0.01, 0.5), \buff: ~buffers[msg[1]], \rate: msg[3] * rrand(-3, 3), \pan: msg[2], \pos: msg[4], \spr: msg[5], \out: ~rev]);
        ~synths.put(msg[6], x);
        x.onFree({~total = ~total - 1; ~synths.removeAt(msg[6]);});
        ~total = ~total + 1;
        //~total.postln;
    }, {});
}, "/makesynth");

 OSCdef(\control, {|msg|
    ~synths[msg[1]].set(\freq2, msg[2]);
 }, "/control");

}
)
