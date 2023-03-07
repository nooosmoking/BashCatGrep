#!/bin/bash

SUCCESS=0
FAIL=0
COUNTER=0
RESULT=0
DIFF_RES=""
no_file="VAR break no_file.txt tests.txt"

declare -a tests=(
"VAR"
"VAR a tests.txt"
"VAR "par*" tests.txt"
"VAR -e a -e "par*" tests.txt"
)

testing()
{
    t=$(echo $@ | sed "s/VAR/$var/")
    leaks -quiet -atExit -- ./s21_grep $t > test_s21_grep.log
    leak=$(grep -A100000 leaks test_s21_grep.log)
    
    (( COUNTER++ ))
    if [[ $leak == *"0 leaks for 0 total leaked bytes"* ]]
    then
      (( SUCCESS++ ))
        echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[32msuccess\033[0m grep $t"
    else
      (( FAIL++ ))
        echo -e "\033[31m$FAIL\033[0m/\033[32m$SUCCESS\033[0m/$COUNTER \033[31mfail\033[0m grep $t"
    fi
    rm test_s21_grep.log
}

testing
testing a
testing "tests.txt"

for var1 in v c l n i
do
    for i in "${tests[@]}"
    do
        var="-$var1"
        testing $i
        testing $no_file
    done
done

# for var1 in v c l n i
# do
#     for var2 in v c l n i
#     do
#         if [ $var1 != $var2 ]
#         then
#             for i in "${tests[@]}"
#             do
#                 var="-$var1 -$var2"
#                 testing $i
#                 testing $no_file
#             done
#         fi
#     done
# done

echo -e "\033[31mFAIL: $FAIL\033[0m"
echo -e "\033[32mSUCCESS: $SUCCESS\033[0m"
echo -e "ALL: $COUNTER"
