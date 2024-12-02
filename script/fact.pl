
use Function::Parameters;

print factorial(5);

fun factorial($n) {
    return 1 if $n <= 1;
    return $n * factorial($n - 1);
}