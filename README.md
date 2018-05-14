# Make for Reproducible Analysis

## Step 1: Brainstorming

### 1.1 What problem(s) will student learn how to solve?

* How to break a workflow into discrete steps
* Writing reproducible, incrementally-updating data analysis pipelines with Make
* How to make Makefiles more maintainable and less repetitive with macros (variables)
* How to make Makefiles more powerful and less repetitive with pattern rules
* How to speed up pipelines with parallel execution
* How to determine when make is _not_ the right tool for the job
* Debugging with `$(warning)`, `@echo`, `-n`, `-d`

### 1.2 What concepts, skills, & techniques will students learn?

What will be covered:
* Dependencies (code & data)
* Targets, Goals
* Directed Acyclic Graphs (at some level)
* Files as step markets
* Pattern matching
* Automatic / per rule variables
* Dry run
* `touch`
* Parallel execution
* Phony targets
* Default goal
* Delete on error
* .SUFFIXES

What will be left out
* User defined functions
* Conditional compilation
* Recipe lines starting with - or +
* Order-only prerequisite - in retrospect, adds more complexity than it saves

Not yet sure about:
* `$(wildcard )`, `$(subst )`, etc - useful enough for the time?
* recursively defined macros (the more common `=` as opposed to `:=`)
* various GNUisms - should be either pure POSIX for compatibility, or full out GNUisms for clarity where available

### 1.3 What technologies, packages, or functions will students use?

* make (POSIX only?)
* curl, running python scripts
* touch

### 1.4 What terms or jargon will you define?

* Target
* Recipe
* Prerequisites
* Macro
* Dpendency
* Goal
* Expansion
* Pattern
* Overriding variables

### 1.5 What analogies or heuristics will you use to define concepts?

* DAG: Batman getting dressed ("Bioinformatics Algorithms: An Active Learning Approach", Compeau & Pevzner)
    - See also: https://matthias-endler.de/2017/makefiles/

### 1.6 What mistakes or misconceptions do you expect?

* Missing dependencies
* Each line in recipe is a new shell; causes problems with env variables
    - Whereas if you have multi-line rules, if first command errors out don't get useful errors
* Syntax - tabs (of course)
* Order of rules isn't important
* Multiple targets in a rule: makes _any_ of them, not _all_ of them
* Pattern rule matching is 
* Pattern rule is overriden by a specific rule
* Variable overriding can be surprising
* Accidentally generating cyclic set of rules
* Confusion between rather opaque syntax of $* $^ $&lt; etc.
* Trying to use $* as vs % in the prerequisites for a rule

### 1.7 What datasets will you use?

AirBnB data available here: https://s3.amazonaws.com/tomslee-airbnb-data-2/$*.zip

Plan is to go as far as the steps in https://github.com/ljdursi/make_pattern_rules 

Given the URLs of the data, curl commands for downloading, and
python scripts for extracting relevant columns of data and plotting
the results, have a makefile which plots individual city data and
combined plots of the price distribution between cities,  e.g.:

> ** Solution **
> ```
> YEAR := "2017"
> 
> .PHONY: all
> all: figs/chicago.png figs/toronto.png figs/chicago-toronto.png
> 
> .SECONDARY:
> 
> data/raw data/merged data/out figs: 
> 	mkdir -p $@
> 
> data/raw/%.zip data/raw/%: | data/raw
> 	curl -o data/raw/$*.zip "https://s3.amazonaws.com/tomslee-airbnb-data-2/$*.zip"
> 	cd data/raw %* \
> 		&& unzip $*.zip \
> 		&& mv s3_files/$* . \
> 		&& rmdir s3_files
> 
> data/merged/%.csv: data/raw/% src/merge_and_clean.py | data/merged
> 	./src/merge_and_clean.py $< -y $(YEAR) -o $@
> 
> data/out/%_price_per_bedroom.csv: data/merged/%.csv src/price_per_bedroom.py | data/out
> 	./src/price_per_bedroom.py $< -o $@
> 
> figs/%.png: data/out/%_price_per_bedroom.csv src/density_plot.py | figs
> 	./src/density_plot.py $< -o $@
> 
> figs/chicago-toronto.png: data/out/chicago_price_per_bedroom.csv data/out/toronto_price_per_bedroom.csv src/density_plot.py | figs
> 	./src/density_plot.py data/out/chicago_price_per_bedroom.csv data/out/toronto_price_per_bedroom.csv -o $@
> 
> figs/all.png: data/out src/density_plot.py
> 	./src/density_plot.py data/out/*.csv -o $@
> 
> .PHONY: clean
> clean:
> 	rm -f data/merged/toronto.csv
> 	rm -f data/merged/chicago.csv
> 	rm -f data/out/toronto_price_per_bedroom.csv
> 	rm -f data/out/chicago_price_per_bedroom.csv
> 	rm -f figs/toronto.png
> 	rm -f figs/chicago.png
> 	rm -f figs/toronto-chicago.png
> 	rm -f figs/all.png
> ```

<!-- -------------------------------------------------------------------------------- -->

## Step 2: Who is this lesson for?

Student will have taken Intro to the Shell for Data Science.

Using the personas from the authoring pages, not the github repo:

* Coder Chen has used Make or similar build sysetems for development, 
  but using it for data pipelines is new.  Dependencies and targets
  are familar, although there weren't typically as many intermediate
  steps.  Never really had to think about the pattern rules before
  - the ones that they used were built in.

* Advanced Alex is generating data pipelines that are outgrowing
  a simple linear chain of steps that can be handled with Jupyter
  Notebooks or R markdown, and is looking for something that can
  handle more complex flows of data.

<!-- -------------------------------------------------------------------------------- -->

## Step 3: What will the learner do along the way?

MultipleChoiceExercise:

We have a script `rainfall.py` that takes three .csv inputs - one
containing rainfall data by U.S. city, another listing cities by
U.S. state, and a third listing rainfall thresholds by vegetatation
type; it outputs likely vegetation types that could thrive in each state
and a plot of rainfalls by state.

Which of the following would be a correct 

(a) Incorrect - what is listed in the rule definition, and in what order
```
rainfall_city.csv city_country.csv vegetation_requirements.csv: state_rainfall.pdf vegetation_state.csv 
	./rainfall.py rainfall_city.csv city_country.csv vegetation_requirements.csv
```

(b) Almost correct - all of the targets are on the left of the colon, and all of the data requirements on the right.  Are there any prerequsites missing?
```
state_rainfall.pdf vegetation_state.csv: city_country.csv vegetation_requirements.csv rainfall_city.csv 
	./rainfall.py rainfall_city.csv city_country.csv vegetation_requirements.csv
```

(c) Does this describe all of the outputs of running this script
```
state_rainfall.pdf: city_country.csv vegetation_requirements.csv rainfall_city.csv 
	./rainfall.py rainfall_city.csv city_country.csv vegetation_requirements.csv
```

(d) would vegetation_state.csv be an input or an output of this script
```
state_rainfall.pdf: vegetation_state.csv city_country.csv vegetation_requirements.csv rainfall_city.csv 
	./rainfall.py rainfall_city.csv city_country.csv vegetation_requirements.csv
```

(e) Correct!
```
state_rainfall.pdf vegetation_state.csv: city_country.csv vegetation_requirements.csv rainfall_city.csv rainfall.py
	./rainfall.py rainfall_city.csv city_country.csv vegetation_requirements.csv
```

1. Convert linear shell script to simple Makefile
   - Long script that runs the entire pipeline
   - Student breaks it up into logical pieces, or provided broken up into pieces
   - Write a makefile that runs only those pieces that need to be rerun

Exercise: given the script split up into `download_data.sh` (which downloads data into `data/raw/toronto.zip`
and `data/raw/chicago.zip`), `extract_and_clean_data.sh` (which assumes those two zip files are present and
generates `data/merged/toronto.csv` and `data/merged/chicago.csv`), and `plot_figs.sh` (which assumes the
merged .csvs are present and produces `figs/toronto.png` `figs/chicago.png` and `figs/toronto-chicago.png`),
write a simple Makefile containing three rules which will only run those scripts that are necessary.

> **Solution**
> ```
> data/raw/toronto.zip data/raw/chicago.zip: download_data.sh
> 	./download_data.sh 
>
> data/merged/toronto.csv data/merged/chicago.csv: data/raw/toronto.zip data/raw/chicago.zip extract_and_clean_data.sh
> 	./extract_and_clean_data.sh 
>
> figs/toronto.png figs/chicago.png figs/toronto-chicago.png: data/merged/toronto.csv data/merged/chicago.csv plot_figs.sh
> 	./plot_figs.sh
> ```

2. 
   - Write a Make rule to run `bin/patient-total` to recreat the daily dosage file for one patient.
   - Use `touch` on the source file to trigger rule execution for testing.
   - Add a new raw dosage file for that patient and check that the rule runs.

3. Recalculate dependent files.
   - Add a rule to regenerate `results/averages.csv`.
   - Use `touch` to check that programs only run when they need to.
   - Trigger the whole execution chain by adding a new raw dosage file.

4. Use automatic variables.
   - Rewrite existing rules using `$@`, `$^`, and `$<`.

5. Create a tree of dependencies (instead of a linear chain).
   - Add a rule to regenerate `daily/AC1433.csv`.
   - Modify the rule for `results/averages.csv` so that it is updated when it needs to be.
   - Test using `touch` and by adding more data files.
   - See what happens when a daily dosage file is *removed* (answer: nothing).

6. Write a pattern rule.
   - Write a wildcard pattern rule to replace the separate rules for `AC1071` and `AC1433`.
   - Test by adding more data files for each patient.
   - Test again by adding an entirely new patient.

7. Include all dependencies.
   - Modify rules to re-run when their scripts change.

8. Use dummy targets.
   - Write a phony `clean` target.
   - Write a phony `test` target.

9. Use macros.
   - Replace names of input and output directories with macros.
   - Override those macros with command-line definitions.

<!-- -------------------------------------------------------------------------------- -->

## Step 4: How are the concepts connected?

- Simple Rules
  - What is Make?
  - What does a simple rule contain?
  - What are automatic variables?
- Dependencies
  - What is a dependency?
  - How does Make decide which commands to run when?
- Writing Better Rules
  - What is a pattern rule?
  - What is a macro?
  - How can we make execution depend on changes to scripts?
- Configuration
  - How can we use functions to construct sets of files?
  - How can we use command-line parameters to control Make?

The code and datasets are:

- Dosage files.
  - And a Python script to generate random dosage files.
- Python scripts to process dosage files.

<!-- -------------------------------------------------------------------------------- -->

## Step 5: Course Overview

**Course Description**

Make is a tool that keeps track of which files depend on which others,
and updates any files that have fallen out of date.  Originally
invented to help programmers manage complex programs, it is now used
by data analysts to make complex workflows reproducible.  This lesson
will show you how to use core features of Make.

**Learning Objectives**

- Explain what problems Make solves and why it is better than handwritten scripts.
- Identify the targets, dependencies, and actions of rules.
- Trace the execution order of rules in a short Makefile.
- Use automatic variables to shorten rules.
- Use wildcards to write pattern rules.
- Use macros and functions to make Makefiles more readable.
- Use include files and command-line parameters to configure Make.

**Prerequisites**

- Introduction to the Unix Shell for Data Scientists
