# Hkoll Demo

This repository contains a ready-to-use demo setup for Hkoll, a software for text collation, aimed to support an automated workflow for critical editions.

Hkoll is written in Haskell (https://www.haskell.org/),
but no programming skills are required to use it.
This README file provides a documentation and step-by-step instructions for both Windows and Linux (Ubuntu) users.

Content:
- The [Overview](#overview) section sets out the general ideas of Hkoll and its application to philological tasks.
- [Documentation](#documentation) explains the data format of the input files as well as all available configuration and runtime options.
- [How-To](#how-to) tells you how to try it yourself – with your own texts, if you want, but a quickstart example is prepared, too.

## Overview

Hkoll was developed to collate several text versions with one ›main‹ version and calculate an *apparatus criticus* from the differences. Deviations between the *textus constitutus* (called »model«) and one or more transcribed witnesses (called »images«) are classified as addition, omission, transposition or – if none of the former applies – plain variance.

Running Hkoll implies the following steps:
1. **Parsing** model and images (these are provided to the software as separate XML/YAML files and must follow some specific syntax rules, cf. [Data Format](#data-format)).
2. **Normalising** the image readings in order to avoid trivial variants from different spelling.
3. **Aligning** and **collating** the model and images: This is the core of Hkoll’s algorithm, but in a future release it is planned to offer also the use of CollateX (https://collatex.net/) for the alignment.
4. Integrating **standoff** information, i.e. any kind of information linked to a specific part of the model (e.g. philological or other commentary, translation, *apparatus fontium*).
5. Formating the result as one comprehensive **(TEI) XML** file which may serve as input to further processing, e.g. to create HTML or PDF versions.

The main difference to other collation tools is that Hkoll supports a highly automated workflow. Indeed, the idea is that Hkoll calculates the complete edition (taken as information, not as a specific representation, cf. [Thomas Stäcker: *A digital edition is not visible*](https://doi.org/10.26083/tuprints-00019469)) from the given input – model, images, normalisation rules, standoff – without any human interception afterwards. All decisions taken by the editors are instead included into the input files; Hkoll then derives the consequences.

The advantage of such an automated workflow is that it enables additions, corrections, and revisions at any time without the need of manually adjusting the *apparatus criticus*. This is done by Hkoll in short time (seconds to minutes).

## Documentation

Find information about
- [Options](#options), both in the [config file](#config-file) and as [runtime options](#runtime-options)
- [Data format](#data-format) of the involved files
- [Hkoll syntax](#hkoll-syntax) for the _textus constitutus_ and the transcriptions

### Options

General remark: There are two ways to pass options to Hkoll – the config file and runtime options. The config file is required and sufficient for running Hkoll, whereas runtime options are neither required nor sufficient without a config file, but make it easier to change Hkoll’s behaviour temporarily without modifying the config file.

#### Config file

The config file is a YAML file with three sections.

`settings`: General settings for Hkoll, mainly activating or deactivating single steps.
- `logLevel`: Hkoll produces logging information, helping you to fix technical problems, but also verify that automated tasks run as expected, e.g. rule-based normalisation. Available log levels are: *None*, *Step*, *Warn*, *Info* or *Full*.
- `applyCorrection`: Do or do not apply correction/charitable interpretation to replace the actual (e.g. misspelled) reading (*True* or *False*)
- `comparePairwise`: Do or do not compare images to each other in addition to comparing them all to the model (*True* or *False*). Note: This has no effect on the calculated edition, but may reveal insights into the relation among witnesses expressed in the log file.
- `normaliseImages`: Do or do not normalise images, if normalisation rules are specified for a division (*True* or *False*).
- `includeStandoff`: Do or do not integrate standoff, if standoff is specified for a division (*True* or *False*).

`repoRoot`: Assuming that you keep all your project files within one root folder, this value provides the link between Hkoll’s location on your computer and the input files (enter an absolute or relative path seen from Hkoll, e.g. `"../../config"` for »two folder levels up, then in the *config* folder«).

`relPaths`: In this section, the relative paths from the `repoRoot` for input and output files are defined, for one or more divisions (separate texts, e.g. chapters or poems):
- `division`: the name of the division (for human readers)
- `divisionId`: the unique id of the division (for Hkoll)
- `process`: option whether Hkoll processes this division (`True`) or skips it (`False`, e.g. because it is in a non-consistent state)
- `model`, `images`, `normRules`, `normTable`, `standoff`, `output`, `logFile`: paths to the corresponding input and output files.

#### Runtime options

Runtime options overrule settings from the config file.

##### General remarks
- Options are prefixed with `--` (e.g. `--dev`, `--no-norm`).
- Some options require arguments (one or possibly more than one). In the following instructions, arguments are indicated by angle brackets (`<argument>`): replace them with the correct values **without brackets**. If more than one argument can follow an option, this is indicated by square brackets (`<arg>[<possibly-more-args>]`): separate the values by comma (without whitespace).

##### Runtime options in detail
- `--help`: Print the help text, an overview of all available runtime options, and exit immediately. (The output may be more up-to-date than the information in this demo.)
- `--version`: Print the version of the Hkoll executable, and exit immediately.
- `--config-file <path>`: Instead of the standard path and file name (`../Configs.yaml`), use the given path to find the config file. This options gives you more freedom in your project setup.
- `--dev` (›development mode‹): Display variants as transcribed (i.e. without normalisation) and with encoded details (e.g. uncertain readings, suspension of abbreviations). This option supports decision-making during text constitution.
- `--div <divId>[,<divId>]` (›divisions‹): Process only the given divisions (identified by the `divisionId` of the `model` file), ignore all the others. This option accelerates the feedback loop when you are working on a specific division. (Cf. the `process` option in the config file.)
- `--log-level <level>`: Set the logging level to one of the options: *None*, *Step*, *Warn*, *Info*, or *Full*.
- `--no-collat`: Do not collate the images, just process the model. This option may be useful if you are currently working on standoff only.
- `--no-corr`: Do not apply correction/charitable interpretation.
- `--no-norm`: Do not normalise, even if normalisation rules are specified.
- `--no-pairwise`: Pairwise collation may help identifying relations between witnesses, but most of the time only slows down Hkoll to finish.
- `--no-standoff`: Ignore standoff data defined in the config file. This option is useful, if you want to ignore outdated ids (which Hkoll otherwise requires you to fix first), e.g. while you are working on the edition and ids are changing often.
- `--wit <witId>[,<witId>]` (›witnesses‹): Process only the given witnesses (identified by the `witnessId` of the witnesses’ transcription file), ignore all th others. This option accelerates the feedback loop if you are interested only in specific witnesses temporarily.

### Data format

Hkoll only processes input files in a specific data format.
Invalid files cause the program to fail and print an error message from which you can get a hint to the underlying problem (e.g. a missing field or broken syntax).

#### Model (= Edition)

The model represents the edition’s main text (i.e. the editors’ version). If your edition can be split into several (natural or arbitrary) »chunks«, use several model/image sets.

The model can be given as either XML or YAML file. Both of them have the same structure: elements in XML, or keys in YAML.

##### Top-level fields

- `division`: expressive name of the division (e.g. `Chapter 1`)
- `divisionId`: unique identifier of the division (e.g. `ch1`)
- `divisionNr` (optional): floating point number of the division (to define its position among all divisions)
- `transcript`: a list of [sections](#model-section) of any length

##### Model Section

A section is the unit actually collated to its corresponding counterparts. The complete division can be stored in one single section. Using multiple sections, however, provides structure to the division’s text, and allows to manually define corresponding text portions; besides, dividing long texts into sections accelerates the collation.

- `section`: expressive name of the section
- `sectionId`: unique identifier of the section
- `content`: transcription of the _textus constitutus_, following the [Hkoll syntax](#hkoll-syntax)
- `subsecs` (optional): a list of nested sections of the same structure (whether you use a ›flat‹ list of section or a ›deep‹ structure – a tree – is up to you)

#### Images (= Witnesses)

An image represents one witness, i.e. each witness included into the collation has its own YAML file (as of version 1.10.2, XML is not available for witnesses).

Make sure that the image’s structure corresponds to the model.

##### Top-level fields

- `divisionId`: identifier of the division, matching the model
- `witnessId`: unique identifier of the witness (e.g. signature or siglum)
- `transcript`: a list of [sections](#image-section), matching the model in total, but not requiring the same nested structure or order.

##### Image Section

Similar to the [model’s section](#model-section) in general, the image’s section differs a bit:

- `sectionId`: identifier of the section, matching the model’s section
- `content` (optional): full transcription of the witness for the section, following the [Hkoll syntax](#hkoll-syntax) – can be omitted, if instead a list of `fragments` is provded
- `fragments` (optional): list (possibly empty) of [transcription fragments](#image-fragment), if the witness is not transcribed completely (for whatever reason) and if the missing text shall not be indicated as omission – can be omitted, if instead a full transcription is provided as `content`
- `subsecs` (optional): cf. [model](#model-section)

##### Image Fragment

In contrast to the full transcription of a section, image fragments are linked to a specific range of the model’s text – possibly just one word – and thus are defined with the following fields (similar to [standoff](#standoff)):

- `from`: identifier of token of the model, where to begin the collation of the fragment
- `fromW`: »word value« (for words: the reading, for XML elements: their name in angle brackets) of the token referenced by `from`, serving as a validity check
- `to`: identifier of token of the model, where to end the collation of the fragment
- `toW`: »word value« of the token referenced by `to`, serving as a validity check
- `app`: transcription of the fragment, following the [Hkoll syntax](#hkoll-syntax) (from »apparatus«: old wording, may change in the future)

#### Normalisation rules

TODO OMS

#### Standoff

TODO OMS

### Hkoll syntax

Text provided to Hkoll, _textus constituts_ as well as transcriptions, can contain two distinct markup systems: XML and a specific syntax for common philological annotations.

XML from the model is simply forwarded to the output and can thus be used to format the edition’s text.
The Hkoll collation algorithm is agnostic to XML markup present in model and image files, so XML from the images is discarded – with the one exception of XML milestone elements whose names are defined in the [options](#options), e.g. to include witnesses’ page/column breaks into the edition.

Designed in order to encode important philological phenomena like scribe’s corrections or uncertain readings in an easy manner, Hkoll provides a specific markup syntax, loosely inspired by the Leiden Conventions for epigraphy.

TODO OMS

## How-To

There are three examples prepared to demonstrate how Hkoll works:
- `abstract`: basic non-sense examples, useful as a proof-of-concept
- `catullus`: Catullus’ carmen 1 (credits to http://www.catullusonline.org)
- `dante`: incipit of Dante’s Commedia (credits to https://www.dantecommedia.it)


Using Hkoll effectively takes two steps: first running Hkoll, then transforming the output to a more readable HTML format.
Instructions for each step follow, but the easiest way to use Hkoll is running the prepared PowerShell script.

### Run PowerShell script (all-in-one solution)

With only one command, you can run Hkoll and a XSLT transformation for an example of your choice.

Prerequisites:
- You have PowerShell installed on your computer (default on Windows, available for Linux and MacOs: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell).
- You have Java installed.
- You have Saxon available (cf. [below](#based-on-java-recommended-for-non-geeks)).

How-to:

1. Open PowerShell and go to the hkoll-demo folder (or open PowerShell from the hkoll-demo folder).
2. Choose the example (›division‹) to process and get its `divisionId` (from the `Configs.yaml` or any of the model/image files), e.g. `cat` for `catullus`.
3. Run `./RunHkoll.ps1 <divId>` with the divisionId of your choice, e.g. `./RunHkoll.ps1 cat`.
4. That should do. Keep an eye on the console output in case of error messages.

### Run Hkoll

To run Hkoll on one or more of the examples, execute the following steps:

1. Open a terminal/shell/console.
2. Run `cd <path/to>/hkoll-demo/hkoll/bins`
3. Depending on your operating system:
   1. on Linux, run `./linux/Hkoll-1.10.2`
   1. on MacOS, run `./macos/Hkoll-1.8.1` (update pending)
   1. on Windows, run `./windows/Hkoll-1.10.2.exe`
4. Wait, then find the generated files in `<path/to>/hkoll-demo/output`. Keep an eye on the console output.

To generate a more readable HTML version of the collation result, [run XSLT transformation](#run-xslt-transformation).

#### Troubleshooting

##### »Invalid character« exception (Windows)

Problem:
Hkoll starts, but fails with `invalid character` error message.

Possible fix:
Run `chcp 65001` in your console before running Hkoll.

Background:
Probably your console’s code page does not support all characters printed by Hkoll.
You can check the current code page by running `chcp`: if it is not 65001, this may be the error cause.
The command `chcp 65001` sets it to the UTF-8 equivalent and should solve the problem.
(Version 1.9.0 addresses this problem.)

### Run XSLT transformation

Choose one of the following two solutions.

#### Based on Java

Prerequisites:
- You need Java installed on your computer.
- You have Saxon available. Therefore:
  1. Download the latest Saxon HE release from https://github.com/Saxonica/Saxon-HE/tree/main/12/Java (Mai 1st, 2024: `SaxonHE12-4J.zip`).
  2. Unzip the downloaded archive and copy `saxon-he-12-4.jar` (or the newer version you downloaded) somewhere on your computer, then get the path of the file (e.g. `C:/Users/<your-name>/Desktop/saxon-he-12-4.jar`).
  3. Store the path of the Saxon JAR in a new environment variable `SAXON_JAR`.

How-to:

1. Open a terminal/shell/console at `<path/to>/hkoll-demo`.
2. Run `java -cp <path/to>/saxon-he-12-4.jar net.sf.saxon.Transform -t -xi -s:output/<division>.xml -xsl:xsl/simple.xsl -o:output/test.html`. In `-s` (source parameter: what XML file to take as input), replace `<division>` with `abstract`, `catullus` or `dante`.
3. Wait, then find the generated file in `<path/to>/hkoll-demo/output` (unless you changed the `-o` output parameter, it is `test.html`).

#### Based on npm (node package manager)

For this solution, you need npm installed on your computer: https://www.npmjs.com/.

1. Install `xslt3` via `npm install xslt3`.
2. Open a terminal/shell/console at `<path/to>/hkoll-demo`.
3. Run `xslt3 -xsl:xsl/simple.xsl -s:output/<division>.xml -o:output/test.html`. In `-s` (source parameter: what XML file to take as input), replace `<division>` with `abstract`, `catullus` or `dante`.
4. Wait, then find the generated file in `<path/to>/hkoll-demo/output` (unless you changed the `-o` output parameter, it is `test.html`).

### Work on your texts

TODO OMS

Some ideas on experimenting with Hkoll:

- Modify the edition’s or witnesses’ texts and compare Hkoll’s results.
- Add a new witness:
  - Create a new YAML file in `input/abstract`.
  - Imitate the structure of an existing witness file (for details, cf. [Data Format: Images](#images)).
  - Enter the new path to the `images` in `Configs.yaml`.
- Add or change normalisation rules.
- Change [options](#options) (e.g. run Hkoll with `--no-norm` and compare the results).
- Add a new division with model and images:
  - Create the files, enter your own content.
  - Update `Configs.yaml`.
