"""
http://www.usaco.org/index.php?page=viewproblem2&cpid=1156


goal : 6 10 6 2 1 4 0 6 3 1
input: 8 7 5 3 7 4 9 10 2 0

the delta is:
-2, 3, 1, -1, -6, 0, -9, -4, 1, 1 


find all the tops and bottoms,
-2, 3, 1, -1, -6, 0, -9, -4, 1, 1 
==>
-2, 3, -6, 0, -9, 1 
inserts 0 into gap between neg and pos
-2, 0, 3, 0, -6, 0, -9, 0, 1 
it's same as converting the neg to pos
2, 0, 3, 0, 6, 0, 9, 0, 1 
the sum of tops will be the answer

it's same as the sum of abs of [-2, 3, -6, 0, -9, 1]
2 + 3 + 6 + 9 + 1 = 21



0, 7, 4, 17, 7, 46, 0
=>
7-4, 17-7, 46-7
0,  4,   7,    0
   7-4
0, 4, 0
4




delta: [0, 0, 3, 1, 1, 3]


[0, 0, 0, 3, 1, 1, 3]
 ^
          

0

    



7, 4, 17, 7, 16, 8, 9

4

ret = 3 + 10 + 3 + 8 + 5 + 4

7, 4, 17, 7, 16, 8, 9
3, 0, 13, 3, 12, 4, 5
3, 0, 10, 0, 9, 1, 2

3, 0, 10, 0, 8, 0, 1


4 + 3 + 1 + 3 + 10 + 8 + 1


7, 4, 17, 7, 16, 8, 9

4, 7, 8, 9

3 + 10 + 8 + 9



if the array is like multi-peak curve like [7, 4, 17, 7, 16, 6, 9],
it can be solved as:
[7, 4, 17, 7, 16, 6, 9]
remove one top, because tops can't be shared by one tune
[(7), 4, (17), 7, (16), 6, (9)]
==>
[4, 7, 6]
ret += 7-4 + 17-7 + 16-7 + 9-6 => 3+10+9+3=25

do it one more time
[4, (7), 6]
=>
[4, 6]
ret += 7-6

do it one more time
[4, (6)]
=>
[4]
ret += 6-4

then
ret += 4

ret = 32



monotone stack
[7, 4, 17, 7, 16, 6, 9]

find next bottom
[7, 4]
ret += 7-4 | 3
stack: [4]

find next bottom
[4, 17, 7]
ret += 17-7 | 3+10=13
stack: [4, 7] => [7]

find next bottom
[7, 16, 6]
ret += 16-7 | 13+9=22
stack: [7, 6]
since 6 is a new bottom, need to handle 7 as well
ret += 7-6 | 22+1 = 23
stack: [6]

find next bottom
[6, 9] => [9]
ret += 9

ret = 23+9 = 32




"""

import sys




def sub_sol(input_tb_list, start, end):
    
    # tb_list is like 0, [7, 4, 17, 7, 46, 8, 9], 0,
    # remove tops => 7-4 + 17-7 + 46-7 + [4, 7, 8]
    # remove tops => 7-4 + 17-7 + 7-4 + [4]
    # sum them all: 3+10+3+4
    ret = 0
    tb_list = input_tb_list
    while len(tb_list) > 2:
        next_list = []
        for i in range(0, end+1):
            if tb_list[i] > tb_list[i+1]:
                # find top
                if i == start:
                    ret += (tb_list[i] - tb_list[i+1])
                else:
                    ret += min(tb_list[i] - tb_list[i-1], tb_list[i] - tb_list[i+1])
                next_list.append(tb_list[i+1])
        tb_list = next_list


    ret += tb_list[0]
    return ret





def solution(goal, in_list):
    delta = []
    for i in range(len(goal)):
        delta.append(goal[i] - in_list[i])

    # print('delta: {}'.format(delta))

    # find tops and bottoms
    sublist = [delta[0]]
    prev = 0
    for i in range(1, len(delta)-1):
        print(i, prev)
        v = delta[i]

        if v == delta[prev]:
            if prev == 0:
                # i can't be top nor bottom, because it's the same as [0]
                continue
        else:
            # with `prev` update, the following two conditions can cover both
            prev = i

        if v > delta[i+1] and v > delta[prev-1]:
            # top
            sublist.append(v)
        elif v < delta[i+1] and v < delta[prev-1]:
            # bottom
            sublist.append(v)

    # last one is always top or bottom
    if delta[-1] != sublist[-1]:
        sublist.append(delta[-1])

    print('sublist: {}'.format(sublist))

    # insert 0s into the sublist
    if sublist[0] < 0:
        ret_list = [-sublist[0]]
    else:
        ret_list = [sublist[0]]

    for i in range(1, len(sublist)):
        if sublist[i-1] * sublist[i] < 0:
            ret_list.append(0)
        if sublist[i] < 0:
            ret_list.append(-sublist[i])
        else:
            ret_list.append(sublist[i])

    print('ret_list: {}'.format(ret_list))

    idx = 0
    # find the first top
    while idx < len(ret_list)-1:
        if ret_list[idx] > ret_list[idx+1]:
            break
        idx += 1

    ret = 0
    for i in range(idx, len(ret_list), 2):
        if i-1 < 0:
            ret += (ret_list[i] - ret_list[i+1])
            continue
        if i+1 >= len(ret_list):
            ret += (ret_list[i] - ret_list[i-1])
            continue
        ret += max(ret_list[i] - ret_list[i-1], ret_list[i] - ret_list[i+1])

    return ret


# main
# size = int(input())
# goal = [int(x) for x in input().split(' ')]
# in_list = [int(x) for x in input().split(' ')]

lines = open(sys.argv[1]).readlines()
size = int(lines[0].strip())
goal = [int(x) for x in lines[1].strip().split(' ')]
in_list = [int(x) for x in lines[2].strip().split(' ')]

# sanity check
assert len(goal) == size
assert len(in_list) == size

# print(goal)
# print(in_list)

#ret = solution(goal, in_list)

ret = sub_sol([0, 7, 4, 17, 7, 46, 0], 1, 5)

print(ret)
