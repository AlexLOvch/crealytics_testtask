# crealytics_testtask
As for that modifier description:
  It opens last csv file(base on fie name contains date)
  It sorts that file by Clicks field descendand
  It processes sorted file by multiplication some of the fields(with commitions value) to provided values
  It stores what into CSV again, but it input file contains more than LINES_PER_FILE values
    we will have more output files(by LINES_PER_FILE line in each)

Combiner part allow to process several sources and combines they by Keyword ID(maybe data from different reports or maybe different project of some customer). But in this particular case this isn't used, b/c of one source file. But that modifier also tryed to combine all values for equal keys into array(so not only modify but megre also), and then leave only first or last(for LAST_VALUE_WINS) of them, while modifiyng the values.

Idea here probably  in sequential (line by line) processing of big amount of data - by using enumerators, but sort violalate this. So question is - if we have posibility to load full data file(while sorting) why don't we process needed fields there. So if you'd like refactor this code in case of one file processing - I'd add that modifiyng processing immidiatelly after sort of file. But most likely that processing can be(and should be) used with several sources - so I'll try to provide decision for this case.
Plan:
- create a generator for create data example(done for now)
- create specs and extract modifier class from modifier.rb
- create specs and extract merger from modifier class

Short status for 12.09
  - Merger and modifier now is separate universal and customizable classes
  - Processor.rb used for set up needed params and start processing(files produced by old modifier and new processor are equal)

TODO:
- Specs should be added for Merger as well as for Modifier classes
- Processor.rb should be refactored(don't have enought time for that)
- Merger and Modifiyer can be relived from CSV things(like .headers and .fields) to be more universal(in this case they can be used with another data source)
- temp files(like sample etc) should be moved or deleted