"""
Tests for the import_traces function.

Tests error handling for missing required fields in trace JSON files.
"""
import json
import pytest
import tempfile
from pathlib import Path
from typing import List, Dict, Any


# Import the function from the notebook (we'll define it here for testing)
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


class TestImportTraces:
    """Test suite for import_traces function."""
    
    def test_valid_single_trace(self, tmp_path):
        """Test importing a single valid trace."""
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
        assert traces[0]["state"] == "completed"
        assert traces[0]["input"] == {"query": "Hello"}
        assert traces[0]["output"] == {"response": "Hi there!"}
    
    def test_valid_multiple_traces(self, tmp_path):
        """Test importing multiple valid traces."""
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
    
    def test_missing_trace_id(self, tmp_path):
        """Test error handling when trace_id is missing."""
        trace_file = tmp_path / "missing_trace_id.json"
        trace_data = [{
            "state": "completed",
            "input": {"query": "Hello"},
            "output": {"response": "Hi there!"}
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "missing required fields" in str(exc_info.value)
        assert "trace_id" in str(exc_info.value)
    
    def test_missing_state(self, tmp_path):
        """Test error handling when state is missing."""
        trace_file = tmp_path / "missing_state.json"
        trace_data = [{
            "trace_id": "trace_001",
            "input": {"query": "Hello"},
            "output": {"response": "Hi there!"}
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "missing required fields" in str(exc_info.value)
        assert "state" in str(exc_info.value)
    
    def test_missing_input(self, tmp_path):
        """Test error handling when input is missing."""
        trace_file = tmp_path / "missing_input.json"
        trace_data = [{
            "trace_id": "trace_001",
            "state": "completed",
            "output": {"response": "Hi there!"}
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "missing required fields" in str(exc_info.value)
        assert "input" in str(exc_info.value)
    
    def test_missing_output(self, tmp_path):
        """Test error handling when output is missing."""
        trace_file = tmp_path / "missing_output.json"
        trace_data = [{
            "trace_id": "trace_001",
            "state": "completed",
            "input": {"query": "Hello"}
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "missing required fields" in str(exc_info.value)
        assert "output" in str(exc_info.value)
    
    def test_missing_multiple_fields(self, tmp_path):
        """Test error handling when multiple fields are missing."""
        trace_file = tmp_path / "missing_multiple.json"
        trace_data = [{
            "trace_id": "trace_001"
            # Missing state, input, and output
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        error_msg = str(exc_info.value)
        assert "missing required fields" in error_msg
        assert "state" in error_msg
        assert "input" in error_msg
        assert "output" in error_msg
    
    def test_null_field_values(self, tmp_path):
        """Test error handling when required fields have null values."""
        trace_file = tmp_path / "null_values.json"
        trace_data = [{
            "trace_id": "trace_001",
            "state": None,
            "input": {"query": "Hello"},
            "output": {"response": "Hi"}
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "null values" in str(exc_info.value)
        assert "state" in str(exc_info.value)
    
    def test_file_not_found(self):
        """Test error handling when file doesn't exist."""
        with pytest.raises(FileNotFoundError):
            import_traces("nonexistent_file.json")
    
    def test_invalid_json(self, tmp_path):
        """Test error handling for malformed JSON."""
        trace_file = tmp_path / "invalid.json"
        trace_file.write_text("{invalid json content")
        
        with pytest.raises(json.JSONDecodeError):
            import_traces(str(trace_file))
    
    def test_non_dict_non_list_json(self, tmp_path):
        """Test error handling for JSON that's neither dict nor list."""
        trace_file = tmp_path / "string.json"
        trace_file.write_text(json.dumps("just a string"))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "Expected JSON to contain a list or dict" in str(exc_info.value)
    
    def test_list_with_non_dict_elements(self, tmp_path):
        """Test error handling for list containing non-dictionary elements."""
        trace_file = tmp_path / "mixed_types.json"
        trace_data = [
            "not a dict",
            {
                "trace_id": "trace_001",
                "state": "completed",
                "input": {},
                "output": {}
            }
        ]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "not a dictionary" in str(exc_info.value)
    
    def test_empty_list(self, tmp_path):
        """Test error handling for empty trace list."""
        trace_file = tmp_path / "empty.json"
        trace_file.write_text(json.dumps([]))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "No valid traces found" in str(exc_info.value)
    
    def test_mixed_valid_invalid_traces(self, tmp_path):
        """Test that function rejects file with any invalid traces."""
        trace_file = tmp_path / "mixed.json"
        trace_data = [
            {
                "trace_id": "trace_001",
                "state": "completed",
                "input": {},
                "output": {}
            },
            {
                "trace_id": "trace_002",
                "state": "completed"
                # Missing input and output
            }
        ]
        trace_file.write_text(json.dumps(trace_data))
        
        with pytest.raises(ValueError) as exc_info:
            import_traces(str(trace_file))
        
        assert "invalid trace(s)" in str(exc_info.value)
    
    def test_extra_fields_allowed(self, tmp_path):
        """Test that traces can have additional fields beyond required ones."""
        trace_file = tmp_path / "extra_fields.json"
        trace_data = [{
            "trace_id": "trace_001",
            "state": "completed",
            "input": {"query": "Hello"},
            "output": {"response": "Hi"},
            "metadata": {"user": "test_user"},
            "timestamp": "2024-01-01T00:00:00Z"
        }]
        trace_file.write_text(json.dumps(trace_data))
        
        traces = import_traces(str(trace_file))
        
        assert len(traces) == 1
        assert traces[0]["trace_id"] == "trace_001"
        assert traces[0]["metadata"] == {"user": "test_user"}
        assert traces[0]["timestamp"] == "2024-01-01T00:00:00Z"


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v"])
