#! /usr/bin/env perl

use 5.020;
use warnings;


use List::Util 'shuffle';



#====================================================================
# @title  'generate_exams'
# @author Gian-Luca Caluori
# @desc   This script generates student exam files with shuffled answers 
#
#
#         The script solves part 1a of the assignment.
#====================================================================

# Track the next question number...
my $next_num   = 1;


# Numerically bulleted lines look like this...
my $QUESTION_PATTERN = qr{
    ^
    (?<indent> \s*          )
    (?<left>   [[:punct:]]* )
    (?<num>    \d+          )
    (?<right>  [[:punct:]]+ )
    (?<etc>    .*           )
}xs;


# filled answer look like this...
my $CHECKED_ANSWER_PATTERN = qr{
    ^
    (?<indent> \s*          )
    (?<left>   \[ )
    (?<alpha>  [Xx]        )
    (?<right>  \] )
    (?<ans>    .*           )
}xs;

# filled answer look like this...
my $UNCHECKED_ANSWER_PATTERN = qr{
    ^
    (?<indent> \s*          )
    (?<left>   \[ )
    (?<alpha>  [^Xx]        )
    (?<right>  \] )
    (?<ans>    \N*            )
}xs;

# Blank lines look like this...
my $BLANK_LINE = qr{^ \s* $}x;


# Remember all the files in the current directory...
my @dir_filenames = `dir /b`;
chomp @dir_filenames;

open my $filehandle2, '<', "FHNW_entrance_exam_master_file_2017.txt";

# This is the data structure we're building from the text file...
my %config;

my $curr_question = "";
# Process each line...
while (my $nextline = readline($filehandle2)) {

    # Empty lines are immediately printed and are ignored for indent tracking...
    if ($nextline =~ $BLANK_LINE) {
        print $nextline;
    }

    # =====================================
    # Questions are in this version currently treated as numberd lines, in line #108
    # the question is set to the full Question name (used as Hash-Key in #134)
    # ======================================

    # Locate a numerically bulleted line and replace it...
    elsif ($nextline =~ $QUESTION_PATTERN ) {
        my %cap = %+;  # Save named regex captures


        # Update bullet number/letter, and track indent...
        $next_num++;

        # compose the current question, trim indent
        $curr_question = $cap{'left'} . $next_num . $cap{'right'} . $cap{'etc'};
    }


    elsif ($nextline =~ $CHECKED_ANSWER_PATTERN) {
        my %cap = %+;  # Save named regex captures


        my $value = $cap{'indent'} . $cap{'left'} . " " . $cap{'right'} . $cap{'ans'};
        push $config{$curr_question}->@*, $value;
    }

    elsif ($nextline =~ $UNCHECKED_ANSWER_PATTERN) {
        my %cap = %+;  # Save named regex captures



        my $value = $cap{'indent'} . $cap{'left'} . " " . $cap{'right'} . $cap{'ans'};
        push $config{$curr_question}->@*, $value;
    }


    else {
        # DO NOTHING
    }

    # =======================================================================
    #    Randomize order of answers (Task 1a)
    # =======================================================================

    sub shuffle_answers{
        # loop over all questions and randomize answers
        for my $nextkey (keys %config){
            # say (  $config{$nextkey}->[1]   );
            my @myvar = shuffle  @{ $config{$nextkey}}   ;


            $config{$nextkey}->@* = @myvar;

            # for debugging
            #push $saveDebugValues{$curr_question}->@*, @myvar;
        }
    }





}


# =======================================================================
#    Write out to file
# =======================================================================

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

my $timestring = "$year $mon $mday-$hour $min";

# add a random number of different exam-files (disabled)

shuffle_answers();


# Opening resulting file in write mode
open (my $fh, ">", "$timestring-IntroPerlEntryExam.txt");
my $renumber_next_num = 1;
for my $nextkey (keys %config){

    my @allAnswers =  @{ $config{$nextkey}}   ;

    # renumber questions
    $nextkey =~ s/\d+/$renumber_next_num/g;
    $renumber_next_num++;

    # pretty output for each questions the possible answers
    my $line = "$nextkey \n ";
    for(@allAnswers){

        $line = $line . $_ ."  \n  " ;
    }
    $line = $line . "\n " . "__" x 50 . "\n";




    # Writing to the file
    print $fh $line;

    # say " aaaaaaaaaaaaaaaa  $a"


    # for debugging
    #push $saveDebugValues{$curr_question}->@*, @myvar;
}
# Closing the file
close($fh) or warn("Couldn't close the file");