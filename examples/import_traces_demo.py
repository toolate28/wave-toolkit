"""
Demonstration of the import_traces() function.

This script shows how to use the import_traces() function with various scenarios.
"""
import json
import tempfile
from pathlib import Path


# The import_traces function (from project-book.ipynb)
def import_traces(json_file_path):
    """
    Import trace data from a JSON file with proper error handling.
    
    See project-book.ipynb for full implementation.
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
        error_summary += "\n".join(f"  - {err}" for err in errors[:5])
        if len(errors) > 5:
            error_summary += f"\n  ... and {len(errors) - 5} more error(s)"
        raise ValueError(error_summary)
    
    if not validated_traces:
        raise ValueError(f"No valid traces found in {json_file_path}")
    
    return validated_traces


def demo():
    """Run demonstration scenarios."""
    print("🔍 import_traces() Function Demonstration")
    print("=" * 60)
    
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        
        # Demo 1: Valid trace import
        print("\n📋 Demo 1: Importing valid trace data")
        print("-" * 60)
        valid_file = tmp_path / "valid_traces.json"
        valid_data = [
            {
                "trace_id": "trace_001",
                "state": "completed",
                "input": {"query": "What is AI?"},
                "output": {"response": "AI stands for Artificial Intelligence"}
            },
            {
                "trace_id": "trace_002",
                "state": "pending",
                "input": {"query": "How does ML work?"},
                "output": {}
            }
        ]
        valid_file.write_text(json.dumps(valid_data, indent=2))
        
        try:
            traces = import_traces(str(valid_file))
            print(f"✅ Successfully imported {len(traces)} traces:")
            for trace in traces:
                print(f"   - Trace {trace['trace_id']}: {trace['state']}")
        except Exception as e:
            print(f"❌ Error: {e}")
        
        # Demo 2: Missing required field
        print("\n📋 Demo 2: Handling missing required fields")
        print("-" * 60)
        invalid_file = tmp_path / "invalid_traces.json"
        invalid_data = [{
            "trace_id": "trace_003",
            "state": "completed"
            # Missing 'input' and 'output' fields
        }]
        invalid_file.write_text(json.dumps(invalid_data, indent=2))
        
        try:
            traces = import_traces(str(invalid_file))
            print(f"❌ Should have raised an error!")
        except ValueError as e:
            print(f"✅ Caught error as expected:")
            print(f"   {str(e)[:200]}...")
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
        
        # Demo 3: File not found
        print("\n📋 Demo 3: Handling file not found")
        print("-" * 60)
        try:
            traces = import_traces("nonexistent_file.json")
            print(f"❌ Should have raised FileNotFoundError!")
        except FileNotFoundError as e:
            print(f"✅ Caught error as expected:")
            print(f"   {e}")
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
        
        # Demo 4: Invalid JSON
        print("\n📋 Demo 4: Handling invalid JSON")
        print("-" * 60)
        malformed_file = tmp_path / "malformed.json"
        malformed_file.write_text("{not valid json")
        
        try:
            traces = import_traces(str(malformed_file))
            print(f"❌ Should have raised JSONDecodeError!")
        except json.JSONDecodeError as e:
            print(f"✅ Caught error as expected:")
            print(f"   Invalid JSON detected")
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
    
    print("\n" + "=" * 60)
    print("✨ Demonstration complete!")
    print("\nKey Features:")
    print("  • Validates required fields: trace_id, state, input, output")
    print("  • Provides clear error messages for missing/invalid data")
    print("  • Handles FileNotFoundError, JSONDecodeError, ValueError")
    print("  • Supports both single trace objects and arrays")
    print("  • Allows additional fields beyond required ones")


if __name__ == "__main__":
    demo()
