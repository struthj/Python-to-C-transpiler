# This program computes and returns the n'th Fibonacci number.
n = 6
f0 = 0
f1 = 1
i = 0
while True:
    fi = f0 + f1
    f0 = f1
    f1 = fi
    i = i + 1
    if i >= n:
        break

f = f0
