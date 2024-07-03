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
1. **Parsing** model and images (these are provided to the software as separate YAML files and must follow some specific syntax rules, cf. [Data Format](#data-format)).
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

### Options

General remark: There are two ways to pass options to Hkoll – the config file and runtime options. The config file is required and sufficient for running Hkoll, whereas runtime options are neither required nor sufficient without a config file, but make it easier to change Hkoll’s behaviour temporarily without modifying the config file.

#### Config file

The config file is a YAML file with three sections.

`settings`: General settings for Hkoll, mainly activating or deactivating single steps.
- `logLevel`: Hkoll produces logging information, helping you to fix technical problems, but also verify that automated tasks run as expected, e.g. rule-based normalisation. Available log levels are: *None*, *Warn*, *Info* or *Full*.
- `comparePairwise`: Do or do not compare images to each other in addition to comparing them all to the model (*True* or *False*). Note: This has no effect on the calculated edition, but may reveal insights into the relation among witnesses expressed in the log file.
- `normaliseImages`: Do or do not normalise images, if normalisation rules are specified for a division (*True* or *False*).
- `includeStandoff`: Do or do not integrate standoff, if standoff is specified for a division (*True* or *False*).

`repoRoot`: Assuming that you keep all your project files within one root folder, this value provides the link between Hkoll’s location on your computer and the input files (enter an absolute or relative path seen from Hkoll, e.g. `"../../config"` for »two folder levels up, then in the *config* folder«).

`relPaths`: In this section, the relative paths from the `repoRoot` for input and output files are defined, for one or more divisions (separate texts, e.g. chapters or poems):
- `division`: the name of the division (for human readers)
- `divisionId`: the unique id of the division (for Hkoll)
- `process`: option whether Hkoll processes this division (`True`) or skips it (`False`, e.g. because it is in a non-consistent state)
- `model`, `images`, `normRules`, `standoff`, `output`, `logFile`: paths to the corresponding input and output files.

#### Runtime options

Runtime options overrule settings from the config file.

##### General remarks
- Options are prefixed with `--` (e.g. `--dev`, `--no-norm`).
- Some options require arguments (one or possibly more than one). In the following instructions, arguments are indicated by angle brackets (`<argument>`): replace them with the correct values **without brackets**. If more than one argument can follow an option, this is indicated by square brackets (`<arg> [<possibly-more-args>]`): separate the values by whitespace.

##### Runtime options in detail

- `--config-file <path>`: Instead of the standard path and file name (`../Configs.yaml`), use the given path to find the config file. This options gives you more freedom in your project setup.
- `--dev` (›development mode‹): Display variants as transcribed (i.e. without normalisation) and with encoded details (e.g. uncertain readings, suspension of abbreviations). This option supports decision-making during text constitution.
- `--div <divId> [<divId>]` (›divisions‹): Process only the given divisions (identified by the `divisionId` of the `model` file), ignore all the others. This option accelerates the feedback loop when you are working on a specific division. (Cf. the `process` option in the config file.)
- `--log-level <level>`: Set the logging level to one of the options: *None*, *Warn*, *Info*, or *Full*.
- `--no-collat`: Do not collate the images, just process the model. This option may be useful if you are currently working on standoff only.
- `--no-norm`: Do not normalise, even if normalisation rules are specified.
- `--no-pairings`: Pairwise collation may help identifying relations between witnesses, but most of the time only slows down Hkoll to finish.
- `--no-standoff`: Ignore standoff data defined in the config file. This option is useful, if you want to ignore outdated ids (which Hkoll otherwise requires you to fix first), e.g. while you are working on the edition and ids are changing often.
- `--wit <witId> [<witId>]` (›witnesses‹): Process only the given witnesses (identified by the `witnessId` of the witnesses’ transcription file), ignore all th others. This option accelerates the feedback loop if you are interested only in specific witnesses temporarily.

### Data format

#### Model

TODO OMS

#### Images

TODO OMS

#### Normalisation rules

TODO OMS

#### Standoff

TODO OMS

## How-To

### Run Hkoll (quickstart example)

There are three examples prepared to demonstrate how Hkoll works:
- `abstract`: basic non-sense examples, useful as a proof-of-concept
- `catull`: Catullus’ carmen 1 (credits to http://www.catullusonline.org)
- `dante`: incipit of Dante’s Commedia (credits to https://www.dantecommedia.it)

#### Windows

1. Open a console, e.g. PowerShell or cmd.
2. Run `cd <path/to>/hkoll-demo/hkoll/bins`
3. Run `./Hkoll-1.6.0.exe`
4. Wait, then find the generated files in `<path/to>/hkoll-demo/output`. Keep an eye on the console output.

To generate a more readable HTML version of the collation result, [run XSLT transformation](#run-xslt-transformation).

#### Linux (Ubuntu)

1. Open a console/terminal.
2. Run `cd <path/to>/hkoll-demo/hkoll/bins`
3. Run `./Hkoll-1.6.0`
4. Wait, then find the generated files in `<path/to>/hkoll-demo/output`. Keep an eye on the console output.

To generate a more readable HTML version of the collation result, [run XSLT transformation](#run-xslt-transformation).

### Run XSLT transformation

#### Based on Java (recommended for non-geeks)

You need Java installed on your computer. This is usually the case.

1. Download the latest Saxon HE release from https://github.com/Saxonica/Saxon-HE/tree/main/12/Java (Mai 1st, 2024: `SaxonHE12-4J.zip`).
2. Unzip the downloaded archive and copy `saxon-he-12-4.jar` (or the newer version you downloaded) somewhere on your computer, then get the path of the file (e.g. `C:/Users/johndoe/Desktop/saxon-he-12-4.jar`).
3. Open a console/terminal at `<path/to>/hkoll-demo`.
4. Run `java -cp <path/to/saxon-he-12-4.jar> net.sf.saxon.Transform -t -xi -s:output/collated.xml -xsl:xsl/simple.xsl -o:output/test.html`.
5. Wait, then find the generated file in `<path/to>/hkoll-demo/output`.

Note: If necessary, replace the paths for the source (`-s` – what XML to take as input) and output (`-o` – where to store the result) files.

#### Based on npm (node package manager)

For this solution, you need npm installed on your computer: https://www.npmjs.com/.

1. Install `xslt3` via `npm install xslt3`.
2. Open a console/terminal at `<path/to>/hkoll-demo`.
3. Run `xslt3 -xsl:xsl/simple.xsl -s:output/collated.xml -o:output/test.html`.
4. Wait, then find the generated file in `<path/to>/hkoll-demo/output`.

Note: If necessary, replace the paths for the source (`-s` – what XML to take as input) and output (`-o` – where to store the result) files.

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
