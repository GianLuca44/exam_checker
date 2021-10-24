package My::Utils 0.000001;

#====================================================================
# @title  'score_exams'
# @author Gian-Luca Caluori
# @desc   This module provides the functionality to read in a exam file and
#         creates a internal datastructure. For all type of files (master, student-responses)
#         the 'read_exam_file' function will be used. 
#         
# parameters  - $filehandle, $file_name
# return values 
#   \%studentAnswer_collection,   => reference to the datastructure
#    $question_count              => number of questions
#    @allTransmittedAnswers       => all answers for transmission_proof
# 
# 
#====================================================================

# ===================================================================
#  IMPORTS                                                          #
# ===================================================================
use 5.026;
use warnings;
use experimentals;

use Exporter::Attributes 'import';


# ======================================
# Definitions
# ======================================

# Numerically bulleted lines look like this...
my $QUESTION_PATTERN = qr{
    ^
    (?<indent> \s*          )
    (?<left>   [[:punct:]]* )
    (?<num>    \d+          )
    (?<right>  [[:punct:]]+ )
    (?<etc>    .*           )
}xs;

# Alpha bulleted lines look like this...
my $ALPHA_LINE = qr{
    ^
    (?<indent> \s*          )
    (?<left>   [[:punct:]]* )
    (?<alpha>  [a-z]        )
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


my $PATH_PATTERN = qr{
    ^
    (?<path> \N*?   [/\] )
    (?<filename> [^\/] \w+_   )
    (?<star>  [*]            )
    (?<filetype> [.]\w*  $   )
}xs;

# Blank lines look like this...
my $BLANK_LINE = qr{^ \s* $}x;

my $curr_question = "";


# =============================================
# main functionality
# =============================================
sub read_exam_file :Exported ($filehandle, $filename){
    my $fhh = $_[0];
    my $file_name = $_[1];

    # collection for transmission proof
    my @allTransmittedAnswers;

    # reset collection at start of method
    my %studentAnswer_collection = ();
    my %collection_of_all_questions_in_file = ();


    my $question_count = 0;

    while (my $nextline = readline($fhh)) {

        if ($nextline =~ $BLANK_LINE) {
            # do nothing
        }

        # =====================================
        # the question is set to the full Question name (used as Hash-Key)
        # ======================================

        # Locate a numerically bulleted line and replace it...
        elsif ($nextline =~ $QUESTION_PATTERN) {
            my %cap = %+; # Save named regex captures


            # compose the current question, trim indent, normalize text
            $curr_question =  $cap{'etc'};

	    # increase number of questions
	    $question_count++; 

            # create a collection of all questions
            $collection_of_all_questions_in_file{$curr_question} = $curr_question;
        }

        # ------------------------------------------------
        ## this is the block where checked answers got detected
        # ------------------------------------------------
        elsif ($nextline =~ $CHECKED_ANSWER_PATTERN) {
            my %cap = %+; # Save named regex captures


            my $value =  $cap{'ans'};

            # save the student answer(s) for each question
            push $studentAnswer_collection{$curr_question}->@*, $value;

            # keep all answers seperatly for file transmission proof
            push @allTransmittedAnswers, $value;

        }
        elsif ($nextline =~ $UNCHECKED_ANSWER_PATTERN) {
            my %cap = %+; # Save named regex captures

            my $value =  $cap{'ans'};

            # keep all answers seperatly for file transmission proof
            push @allTransmittedAnswers, $value;
        }

        else {
            # do nothing
        }


    }
	
    return \%studentAnswer_collection, $question_count, @allTransmittedAnswers;

}

1; # Magic true value required at end of module

