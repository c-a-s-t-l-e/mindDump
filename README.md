# mindDump

Journals are important... so why not make things easier for yourself?

## What's a "Mind Dump"?

If you really can't get yourself to focus on planning out your day or week, 
why not do a mind dump?

Essentially, there are two easy steps:

1. Start writing or typing what's on your mind.

2. That's it.

## mindDump's Purpose

After a pretty big mind dump, there might be some handy stuff in there that you could
recycle for other purposes like figuring out what makes us tick.

Sometimes you can get a lot of it yourself, but wouldn't it be nice to have
a handy-dandy tool to help you as well?

mindDump's that tool!

---

## What Does This Project Entail?

There are three separable, mostly independent components to this project that are meant to be modified by the user.

These are:

1. [The mindDump Android App](android_app)
2. [The Journal Entry Processing Notebooks](model_notebook)
3. [The mindDump Analyser Web App](web_app)


!()[(http://mindDump/demo/images/mindDumpProcess.png]

---

### Quesions About the Mobile App

#### Why Did You Design The Mobile App The Way You Did?

When originaly setting out to build the mobile app, my top two desires were:

1. No spellcheck so that way somebody who's dumping their mind won't be bothered to correct their typos.
2. Bare minimum aesthetics so that way (once again) there's no distractions when typing down your thoughts.

---

### Questions About the Notebooks

#### Why An ONNX Model?

ONNX models are known for their [interoperability](https://onnx.ai/index.html). Something that is desirable if you want to share things with others.

#### Does the Model Have Any Weaknesses?

Yes. The model has been fine-tuned on the Go Emotions dataset. After quite a bit of user testing, it appears that there may be some mislabeling in the training data among other issues. These then affect the model's performance on our parsed journal entries.

#### Is There a Specific Reason Why You Process the Journal Entry Texts The Way You Decided To?

Yes. Since we're are working with mind-dumped data, punctuation is probably not going to be the best. To account for this, excessive spacing as well as traditional punctuation markers are used to produce sentences.

---

### Questions About the Web App

#### Do the CSVs You Load Into the App Have To Have a Specific Format?

Yes. The respective column names/format for the csv should consist of doc_id, date, year, month, day, hour, sentence, text, and any number of emotion columns with their respective scores ranging from 0 to 1.

#### How Did You Manage To Get Free Web Hosting for The Web App?

By using the shinylive package and Github Pages. This [guide](https://github.com/RamiKrispin/shinylive-r) is pretty useful.
