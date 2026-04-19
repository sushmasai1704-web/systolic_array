import random

def matmul(A, B, N):
    C = [[0]*N for _ in range(N)]
    for i in range(N):
        for j in range(N):
            for k in range(N):
                C[i][j] += A[i][k] * B[k][j]
    return C

N = 4

# Fixed test matrix
A = [[1,2,3,4],
     [5,6,7,8],
     [9,10,11,12],
     [13,14,15,16]]

B = [[1,0,0,0],
     [0,1,0,0],
     [0,0,1,0],
     [0,0,0,1]]  # Identity matrix

C = matmul(A, B, N)

print("=== Golden Model: 4x4 Matrix Multiply ===")
print("A =")
for row in A: print(" ", row)
print("B = Identity")
print("C = A x B =")
for row in C: print(" ", row)

# Write test vectors for RTL
with open("model/test_vectors.txt", "w") as f:
    # Write A row by row
    for i in range(N):
        for j in range(N):
            f.write(f"{A[i][j]:08x}\n")
    # Write B col by col (weight stationary)
    for j in range(N):
        for i in range(N):
            f.write(f"{B[i][j]:08x}\n")
    # Write expected C
    for i in range(N):
        for j in range(N):
            f.write(f"{C[i][j]:08x}\n")

print("\nTest vectors written to model/test_vectors.txt")
print("Expected C[0][0] =", C[0][0])
print("Expected C[3][3] =", C[3][3])
