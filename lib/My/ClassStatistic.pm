package My::ClassStatistic 0.000001;

use 5.010;
use warnings;
use strict;

use experimentals;

use Exporter::Attributes 'import';

use List::Util qw< min max >;
use Statistics::Basic qw< mean mode median >;

use POSIX; # ceil, floor functions

sub print_header{
    say "="x40 ;
    say "# STATISTICS        #  ";
    say "="x40;
}

sub report_class_result_statistics :Exported {
    # load the values from method parameter
    my @values = @_;

    print_header();

    my $noOfAnswers = @values;
    say "Number of scored student-responses ....." . $noOfAnswers;

    # Report...
    say "Average number of correct answers........ ", ceil(  mean(@values) );
    say "min   = ", min(@values) ;
    say "max   = ", max(@values) ;
}

1; # Magic true value required at end of module
