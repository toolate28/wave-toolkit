"""
Tests for Euler's number usage examples.

Ensures that the correct exponential calculations produce accurate results
and demonstrates the precision difference between methods.
"""

import math
import sys
from pathlib import Path

# Add the examples directory to the path
sys.path.insert(0, str(Path(__file__).parent.parent / "examples"))

import euler_number_usage


def test_correct_exponential_exp():
    """Test that math.exp() produces correct results."""
    delta = 5.0
    temperature = 10.0
    result = euler_number_usage.correct_exponential_exp(delta, temperature)
    expected = math.exp(0.5)  # 5.0 / 10.0 = 0.5
    
    assert abs(result - expected) < 1e-10, f"Expected {expected}, got {result}"
    print("✓ test_correct_exponential_exp passed")


def test_correct_exponential_pow():
    """Test that pow(math.e, x) produces correct results."""
    delta = 5.0
    temperature = 10.0
    result = euler_number_usage.correct_exponential_pow(delta, temperature)
    expected = math.exp(0.5)
    
    assert abs(result - expected) < 1e-10, f"Expected {expected}, got {result}"
    print("✓ test_correct_exponential_pow passed")


def test_incorrect_is_less_accurate():
    """Test that the hardcoded approximation is less accurate."""
    delta = 5.0
    temperature = 10.0
    
    incorrect = euler_number_usage.incorrect_exponential_approximation(delta, temperature)
    correct = euler_number_usage.correct_exponential_exp(delta, temperature)
    
    # The incorrect method should have a measurable error
    error = abs(incorrect - correct)
    assert error > 1e-6, f"Expected significant error, but got {error}"
    print(f"✓ test_incorrect_is_less_accurate passed (error: {error:.2e})")


def test_simulated_annealing_acceptance():
    """Test simulated annealing acceptance probability calculations."""
    # Test 1: Negative delta (better solution) - should always accept
    result = euler_number_usage.simulated_annealing_acceptance_probability(-10.0, 100.0)
    assert result == 1.0, f"Expected 1.0 for better solution, got {result}"
    
    # Test 2: Zero temperature - should never accept worse solutions
    result = euler_number_usage.simulated_annealing_acceptance_probability(10.0, 0.0)
    assert result == 0.0, f"Expected 0.0 for zero temperature, got {result}"
    
    # Test 3: Normal case - should return value between 0 and 1
    result = euler_number_usage.simulated_annealing_acceptance_probability(5.0, 10.0)
    assert 0.0 < result < 1.0, f"Expected value between 0 and 1, got {result}"
    
    # Test 4: High temperature - should accept almost anything
    result = euler_number_usage.simulated_annealing_acceptance_probability(1.0, 1000.0)
    assert result > 0.99, f"Expected high acceptance at high temperature, got {result}"
    
    print("✓ test_simulated_annealing_acceptance passed")


def test_math_e_precision():
    """Test that math.e is more precise than 2.718."""
    hardcoded = 2.718
    accurate = math.e
    
    error = abs(hardcoded - accurate)
    assert error > 1e-4, f"Expected measurable error between 2.718 and math.e"
    assert accurate > hardcoded, "math.e should be greater than 2.718"
    
    print(f"✓ test_math_e_precision passed (error: {error:.2e})")


def run_all_tests():
    """Run all tests."""
    print("Running Euler's Number Usage Tests")
    print("=" * 50)
    
    tests = [
        test_correct_exponential_exp,
        test_correct_exponential_pow,
        test_incorrect_is_less_accurate,
        test_simulated_annealing_acceptance,
        test_math_e_precision,
    ]
    
    for test in tests:
        try:
            test()
        except AssertionError as e:
            print(f"✗ {test.__name__} failed: {e}")
            return False
    
    print("=" * 50)
    print("All tests passed!")
    return True


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
