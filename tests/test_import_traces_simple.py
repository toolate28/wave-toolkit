"""
Simple test runner for import_traces function (no pytest dependency).
"""
import json
import tempfile
from pathlib import Path
from typing import List, Dict, Any


# Import the function implementation
def import_traces(json_file_path: str) -> List[Dict[str, Any]]:
    """
    Import trace data from a JSON file with proper error handling.
    
    Handles JSON files containing trace data with required fields:
    - trace_id: Unique identifier for the trace
    - state: Current state of the trace
    - input: Input data for the trace
    - output: Output data from the trace
    
    Args:
        json_file_path: Path to the JSON file containing trace data
        
    Returns:
        List of trace dictionaries with validated fields
        
    Raises:
        FileNotFoundError: If the JSON file doesn't exist
        json.JSONDecodeError: If the file contains invalid JSON
        ValueError: If required fields are missing or invalid
    """
    # Check if file exists
    if not Path(json_file_path).exists():
        raise FileNotFoundError(f"Trace file not found: {json_file_path}")
    
    # Read and parse JSON
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        raise json.JSONDecodeError(
            f"Invalid JSON in file {json_file_path}: {str(e)}", 
            e.doc, 
            e.pos
        )
    
    # Ensure data is a list
    if isinstance(data, dict):
        # If it's a single trace object, wrap it in a list
        data = [data]
    elif not isinstance(data, list):
        raise ValueError(
            f"Expected JSON to contain a list or dict, got {type(data).__name__}"
        )
    
    # Required fields for trace data
    required_fields = ['trace_id', 'state', 'input', 'output']
    
    # Validate each trace
    validated_traces = []
    errors = []
    
    for idx, trace in enumerate(data):
        if not isinstance(trace, dict):
            errors.append(f"Trace at index {idx} is not a dictionary: {type(trace).__name__}")
            continue
        
        # Check for missing required fields
        missing_fields = [field for field in required_fields if field not in trace]
        
        if missing_fields:
            # Build a helpful error message
            error_msg = (
                f"Trace at index {idx} is missing required fields: {', '.join(missing_fields)}. "
                f"Available fields: {', '.join(trace.keys()) if trace.keys() else 'none'}. "
                f"Required fields are: {', '.join(required_fields)}"
            )
            errors.append(error_msg)
            continue
        
        # Validate that required fields are not None
        none_fields = [field for field in required_fields if trace[field] is None]
        if none_fields:
            error_msg = (
                f"Trace at index {idx} has null values for required fields: {', '.join(none_fields)}"
            )
            errors.append(error_msg)
            continue
        
        validated_traces.append(trace)
    
    # If we have errors, raise a comprehensive error message
    if errors:
        error_summary = f"Found {len(errors)} invalid trace(s) in {json_file_path}:\n"
        error_summary += "\n".join(f"  - {err}" for err in errors[:5])  # Show first 5 errors
        if len(errors) > 5:
            error_summary += f"\n  ... and {len(errors) - 5} more error(s)"
        raise ValueError(error_summary)
    
    if not validated_traces:
        raise ValueError(f"No valid traces found in {json_file_path}")
    
    return validated_traces


def run_tests():
    """Run all tests for import_traces."""
    passed = 0
    failed = 0
    
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        
        # Test 1: Valid single trace
        print("Test 1: Valid single trace... ", end="")
        try:
            trace_file = tmp_path / "single_trace.json"
            trace_data = {
                "trace_id": "trace_001",
                "state": "completed",
                "input": {"query": "Hello"},
                "output": {"response": "Hi there!"}
            }
            trace_file.write_text(json.dumps(trace_data))
            traces = import_traces(str(trace_file))
            assert len(traces) == 1
            assert traces[0]["trace_id"] == "trace_001"
            print("✅ PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ FAILED: {e}")
            failed += 1
        
        # Test 2: Valid multiple traces
        print("Test 2: Valid multiple traces... ", end="")
        try:
            trace_file = tmp_path / "multiple_traces.json"
            trace_data = [
                {
                    "trace_id": "trace_001",
                    "state": "completed",
                    "input": {"query": "Hello"},
                    "output": {"response": "Hi there!"}
                },
                {
                    "trace_id": "trace_002",
                    "state": "pending",
                    "input": {"query": "How are you?"},
                    "output": {}
                }
            ]
            trace_file.write_text(json.dumps(trace_data))
            traces = import_traces(str(trace_file))
            assert len(traces) == 2
            assert traces[0]["trace_id"] == "trace_001"
            assert traces[1]["trace_id"] == "trace_002"
            print("✅ PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ FAILED: {e}")
            failed += 1
        
        # Test 3: Missing trace_id
        print("Test 3: Missing trace_id raises ValueError... ", end="")
        try:
            trace_file = tmp_path / "missing_trace_id.json"
            trace_data = [{
                "state": "completed",
                "input": {"query": "Hello"},
                "output": {"response": "Hi there!"}
            }]
            trace_file.write_text(json.dumps(trace_data))
            import_traces(str(trace_file))
            print("❌ FAILED: Should have raised ValueError")
            failed += 1
        except ValueError as e:
            if "missing required fields" in str(e) and "trace_id" in str(e):
                print("✅ PASSED")
                passed += 1
            else:
                print(f"❌ FAILED: Wrong error message: {e}")
                failed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 4: Missing state
        print("Test 4: Missing state raises ValueError... ", end="")
        try:
            trace_file = tmp_path / "missing_state.json"
            trace_data = [{
                "trace_id": "trace_001",
                "input": {"query": "Hello"},
                "output": {"response": "Hi there!"}
            }]
            trace_file.write_text(json.dumps(trace_data))
            import_traces(str(trace_file))
            print("❌ FAILED: Should have raised ValueError")
            failed += 1
        except ValueError as e:
            if "missing required fields" in str(e) and "state" in str(e):
                print("✅ PASSED")
                passed += 1
            else:
                print(f"❌ FAILED: Wrong error message: {e}")
                failed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 5: Missing input
        print("Test 5: Missing input raises ValueError... ", end="")
        try:
            trace_file = tmp_path / "missing_input.json"
            trace_data = [{
                "trace_id": "trace_001",
                "state": "completed",
                "output": {"response": "Hi there!"}
            }]
            trace_file.write_text(json.dumps(trace_data))
            import_traces(str(trace_file))
            print("❌ FAILED: Should have raised ValueError")
            failed += 1
        except ValueError as e:
            if "missing required fields" in str(e) and "input" in str(e):
                print("✅ PASSED")
                passed += 1
            else:
                print(f"❌ FAILED: Wrong error message: {e}")
                failed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 6: Missing output
        print("Test 6: Missing output raises ValueError... ", end="")
        try:
            trace_file = tmp_path / "missing_output.json"
            trace_data = [{
                "trace_id": "trace_001",
                "state": "completed",
                "input": {"query": "Hello"}
            }]
            trace_file.write_text(json.dumps(trace_data))
            import_traces(str(trace_file))
            print("❌ FAILED: Should have raised ValueError")
            failed += 1
        except ValueError as e:
            if "missing required fields" in str(e) and "output" in str(e):
                print("✅ PASSED")
                passed += 1
            else:
                print(f"❌ FAILED: Wrong error message: {e}")
                failed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 7: File not found
        print("Test 7: File not found raises FileNotFoundError... ", end="")
        try:
            import_traces("nonexistent_file.json")
            print("❌ FAILED: Should have raised FileNotFoundError")
            failed += 1
        except FileNotFoundError:
            print("✅ PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 8: Invalid JSON
        print("Test 8: Invalid JSON raises JSONDecodeError... ", end="")
        try:
            trace_file = tmp_path / "invalid.json"
            trace_file.write_text("{invalid json content")
            import_traces(str(trace_file))
            print("❌ FAILED: Should have raised JSONDecodeError")
            failed += 1
        except json.JSONDecodeError:
            print("✅ PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 9: Null field values
        print("Test 9: Null field values raises ValueError... ", end="")
        try:
            trace_file = tmp_path / "null_values.json"
            trace_data = [{
                "trace_id": "trace_001",
                "state": None,
                "input": {"query": "Hello"},
                "output": {"response": "Hi"}
            }]
            trace_file.write_text(json.dumps(trace_data))
            import_traces(str(trace_file))
            print("❌ FAILED: Should have raised ValueError")
            failed += 1
        except ValueError as e:
            if "null values" in str(e) and "state" in str(e):
                print("✅ PASSED")
                passed += 1
            else:
                print(f"❌ FAILED: Wrong error message: {e}")
                failed += 1
        except Exception as e:
            print(f"❌ FAILED: Unexpected error: {e}")
            failed += 1
        
        # Test 10: Extra fields allowed
        print("Test 10: Extra fields are allowed... ", end="")
        try:
            trace_file = tmp_path / "extra_fields.json"
            trace_data = [{
                "trace_id": "trace_001",
                "state": "completed",
                "input": {"query": "Hello"},
                "output": {"response": "Hi"},
                "metadata": {"user": "test_user"}
            }]
            trace_file.write_text(json.dumps(trace_data))
            traces = import_traces(str(trace_file))
            assert len(traces) == 1
            assert traces[0]["metadata"] == {"user": "test_user"}
            print("✅ PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ FAILED: {e}")
            failed += 1
    
    print(f"\n{'='*60}")
    print(f"Test Results: {passed} passed, {failed} failed out of {passed + failed} tests")
    print('='*60)
    
    return failed == 0


if __name__ == "__main__":
    success = run_tests()
    exit(0 if success else 1)
