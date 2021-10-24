#! /usr/bin/env perl

#====================================================================
# @title  'score_exams'
# @author Gian-Luca Caluori
# @desc   This script reads in a master file and takes a list of response files.
#         It compares the response files against the master file and reports
#         any missing questions or answers in the response files.
#         The response files are scored and a statistic over all students will be made
#         and printed to console
#
#         Call syntax: FHNW_entrance_exam_master_file_2017.txt exam21/[response_file]
#                      FHNW_entrance_exam_master_file_2017.txt exam21/*
#
#         The script solves part 1b, 2, of the assignment.
#====================================================================

use 5.020;
use warnings;
use diagnostics;

# ===================================================================
#  IMPORTS                                                          #
# ===================================================================

use experimental 'signatures';

use Test::More;

use File::Spec 'catdir';
#extract path from filename
use File::Basename;

use Array::Utils qw(array_minus);

# my own statistic Function
use My::ClassStatistic qw(report_class_result_statistics);

use My::Utils;

# ======================================
# Definitions
# ======================================

my $PATH_PATTERN = qr{
    ^
    (?<path> \N*?   [/\] )
    (?<filename> [^\/] \w+_   )
    (?<star>  [*]            )
    (?<filetype> [.]\w*  $   )
}xs;

my %correctAnswers;
my @allAnswers;


my @class_score_values;

# filehandle for masterfile
my $filehandle_master;

# keep the number of expected questions
my $no_of_questions_masterfile;

# =============================================
# main script
# =============================================

open ($filehandle_master, '<', $ARGV[0]) or
    open $filehandle_master, '<', "FHNW_entrance_exam_master_file_2017.txt";


processMasterFile();


# ================
# parse filenames/patterns
# ===============

# ======================================
# Get Student-Files from input parameter
# ======================================


# PATTERN for Student-Files (may contain folder-Names)
if ($ARGV[1] =~$PATH_PATTERN){
    my %cap = %+; # Save named regex captures

    # convert path-slashes to backslash
    $cap{'path'} =~ s/\//\\/g;

    my($filename, $subdirectory, $suffix) = fileparse($cap{'path'});

    # Remember all the files in the current directory...
    my @dir_filenames = `dir $subdirectory /b`;


     # FILTER THE FILENAMES ACCORDING PATTERN
      my @interesting_filenames =  grep{$_ =~ m/$filename/ } @dir_filenames;

    use File::chdir;
    for(@interesting_filenames) {
        # cut point in path at the beginning
        $subdirectory =~ s/\. \\ /\\/g;


        $subdirectory =~ s/\\/\//g;


        my $CWD = Cwd::abs_path . $subdirectory;

        open(my $current_student_filehandle, "<" . $CWD . "/" . $_);
        processStudentFile($current_student_filehandle, $_);
    }
} ;

# calculate and print statistics to console
My::ClassStatistic::report_class_result_statistics(@class_score_values);


# ======================================
# Functions
# ======================================

# ------------------------------------------------
# read in master file
# ------------------------------------------------
sub processMasterFile() {
    my $correct_answers_ref;

    # keep reference on 'correct_answers_collection' and 'allAnswers' (2nd param for error proof)
    ($correct_answers_ref, $no_of_questions_masterfile, @allAnswers)= read_exam_file($filehandle_master, "FHNW_entrance_exam.txt");

    %correctAnswers = %{$correct_answers_ref};

    return \%correctAnswers;
}

# ------------------------------------------------
# read in STUDENT file
# param:
# 1. filehandle
# 2. filename (for report)
# ------------------------------------------------
sub processStudentFile {
    my $fhh = $_[0];
    my $file_name = $_[1];

    # save return values
    # (reference to collection of given answers, "@allTransmittedAnswers" for transmission proof)
    my ($studentAnswer_collection_ref,$question_count ,@allTransmittedAnswers) = read_exam_file($fhh, $file_name);

    my %studentAnswer_collection =  %{$studentAnswer_collection_ref};

    # number of correct questions
    my $score = 0;

    # postprocess studentfile, filter out all questions with more than 1 checkmark
    for my $question (keys %studentAnswer_collection){
        if (@{ $studentAnswer_collection{$question} } ne 1){  # filter out the questions
            delete($studentAnswer_collection{$question});
        };

    }

    # check the answer and increase score
    for my $question_name (keys %studentAnswer_collection){
        # because all arrays of student-answers where more than one answer was given are filtered out,
        # compare the first element do the job

        if( ($correctAnswers{$question_name} -> [0]) eq ($studentAnswer_collection{$question_name} -> [0]) ){
            $score++;
        } ;

    }


    # =================================================
    # print report
    # =================================================

    # structure
    # - filename
    # - score
    # - %{missing questions}
    # - %{missing answers}

    say $file_name . "........". $score . "/" . 30 ."\n\n";

    for( keys %correctAnswers ){
        if($_ eq 'all'){
            next;  # skip this key because it's not a question/answer pair
        }
        say "missing question: " . $_ if ($_ =~ m/\N+/g                          # question shouldn't be empty string
                                            && defined $correctAnswers{$_}
                                            &&  ! defined $studentAnswer_collection{$_} )
    };

    for (my $i=0; $i<@allTransmittedAnswers; ++$i) {
        $allTransmittedAnswers[$i] = normalize_text_string($allTransmittedAnswers[$i]) ;
    }
    for (my $j=0; $j<@allAnswers; ++$j) {
        $allAnswers[$j] = normalize_text_string($allAnswers[$j]) ;
    }

    # calculate missing answers
    my @diff = array_minus(  @allAnswers, @allTransmittedAnswers);

    for my $missing_answer (@diff){
        print "missing answer: " . $missing_answer . "\n";
    }


    say "-" x50;
    push @class_score_values, $score;

    return \%studentAnswer_collection;
}

sub normalize_text_string($string){

    $string =~ s/^\s+|\s+$//g;           # trim
    $string =  lc($string);               # to lower case
    $string =~ s/\s{2,}/ /g;             # replace multiple spaces with one space;

    return $string;
}


print_delimiter();
say "== TESTING SECTION ==";



sub print_delimiter(){
    say "\n\n" ."_" x40;
}

plan tests => 4;

my $size_of_class_score_values = @class_score_values;
my $size_of_allAnswers = @allAnswers;


ok($size_of_class_score_values gt 0);
ok($size_of_allAnswers gt 0);

my $sample_student_score = $class_score_values[0];

# no negative values for score allowed
ok ($sample_student_score ge 0);

# no values greater number of questions allowed
ok ($sample_student_score le $no_of_questions_masterfile);


done_testing();
