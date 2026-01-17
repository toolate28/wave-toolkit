"""
Euler's Number Usage Examples

This module demonstrates the correct way to use Euler's number (e) in Python,
particularly for exponential calculations common in algorithms like simulated
annealing, probability calculations, and exponential decay.

The Python standard library provides more accurate values than hardcoded
approximations.
"""

import math


def incorrect_exponential_approximation(delta, temperature):
    """
    INCORRECT: Using hardcoded approximation of Euler's number.
    
    This approach uses pow(2.718, delta / temperature) which is less accurate
    than using the standard library.
    
    Args:
        delta: The energy difference or delta value
        temperature: The temperature parameter
        
    Returns:
        float: Approximate exponential value (less accurate)
    """
    # ❌ AVOID: Hardcoded approximation - less precise
    return pow(2.718, delta / temperature)


def correct_exponential_exp(delta, temperature):
    """
    CORRECT: Using math.exp() for exponential calculations.
    
    This is the recommended approach for computing e^x. The math.exp() function
    is optimized and provides the most accurate results.
    
    Args:
        delta: The energy difference or delta value
        temperature: The temperature parameter
        
    Returns:
        float: Accurate exponential value
    """
    # ✓ PREFERRED: Use math.exp() - most accurate and efficient
    return math.exp(delta / temperature)


def correct_exponential_pow(delta, temperature):
    """
    CORRECT (Alternative): Using pow() with math.e.
    
    If you prefer the pow() syntax, use math.e for the base. However,
    math.exp() is still preferred for better performance and accuracy.
    
    Args:
        delta: The energy difference or delta value
        temperature: The temperature parameter
        
    Returns:
        float: Accurate exponential value
    """
    # ✓ ACCEPTABLE: Use math.e with pow() - accurate but less common
    return pow(math.e, delta / temperature)


def simulated_annealing_acceptance_probability(delta_energy, temperature):
    """
    Example: Simulated annealing acceptance probability.
    
    In simulated annealing, the acceptance probability for a worse solution
    is calculated as e^(-ΔE/T), where ΔE is the energy difference and T is
    the temperature.
    
    Args:
        delta_energy: Energy difference (positive for worse solutions)
        temperature: Current temperature parameter
        
    Returns:
        float: Acceptance probability between 0 and 1
    """
    if delta_energy < 0:
        # Better solution - always accept
        return 1.0
    
    if temperature <= 0:
        # Zero temperature - never accept worse solutions
        return 0.0
    
    # Calculate acceptance probability using proper exponential
    return math.exp(-delta_energy / temperature)


def compare_accuracy():
    """
    Demonstrates the accuracy difference between methods.
    """
    delta = 5.0
    temperature = 10.0
    
    # Calculate using different methods
    incorrect = incorrect_exponential_approximation(delta, temperature)
    correct_exp = correct_exponential_exp(delta, temperature)
    correct_pow = correct_exponential_pow(delta, temperature)
    
    print("Comparison of Euler's number usage methods:")
    print(f"  Incorrect (2.718 hardcoded):  {incorrect:.15f}")
    print(f"  Correct (math.exp()):         {correct_exp:.15f}")
    print(f"  Correct (pow(math.e, ...)):   {correct_pow:.15f}")
    print(f"\nDifference from math.exp():")
    print(f"  Hardcoded 2.718 error:        {abs(incorrect - correct_exp):.2e}")
    print(f"  pow(math.e, ...) error:       {abs(correct_pow - correct_exp):.2e}")
    
    # Show the actual value of math.e vs approximation
    print(f"\nEuler's number comparison:")
    print(f"  Hardcoded approximation:      2.718")
    print(f"  math.e (actual):              {math.e:.15f}")
    print(f"  Difference:                   {abs(2.718 - math.e):.2e}")


if __name__ == "__main__":
    print("=" * 70)
    print("Euler's Number Usage - Best Practices")
    print("=" * 70)
    print()
    
    compare_accuracy()
    
    print("\n" + "=" * 70)
    print("Recommendation:")
    print("=" * 70)
    print("✓ Use math.exp(x) for computing e^x")
    print("✓ Use math.e if you need the constant value")
    print("✗ Avoid hardcoded approximations like 2.718")
    print()
