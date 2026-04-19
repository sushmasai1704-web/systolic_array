# Test 2: Random non-trivial matrix multiply
A = [[1,2,3,4],
     [5,6,7,8],
     [9,10,11,12],
     [13,14,15,16]]

B = [[2,0,1,0],
     [0,3,0,1],
     [1,0,2,0],
     [0,1,0,3]]

N = 4
C = [[sum(A[i][k]*B[k][j] for k in range(N)) for j in range(N)] for i in range(N)]

print("A x B =")
for row in C: print(" ", row)
