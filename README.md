## ExamChecker
Perl project to automatically create and mark exams. The application consists of two scripts and two modules:

1a_create_exam.pl (part 1a)
1b_scoreExam.pl (part 1b, 2)

My::ClassStatistic.pm (part 3)
My::Utils.pm  (read in and process textfile)

### Usage
All files must be called from the directory where the script is placed.

To examine the exam files, place them in the 'Task1b/exam21' directory.

Call syntax: perl 1b_scoreExam.pl FHNW_entrance_exam_master_file_2017.txt exam21/student_*.txt
This will check all files with the prefix 'student_', but no other like 'filename_not_match_pattern.txt'
