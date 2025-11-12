# Stack Trace Visualization Proposal for ChatDBG

## Executive Summary

**Yes, ChatDBG already captures all the data needed for rich stack trace visualization!** The codebase currently has:

- ✅ Full stack trace with all frames
- ✅ Variable values for each frame (with type information)
- ✅ Source code context for each frame
- ✅ Call hierarchy (frame relationships)
- ✅ Current frame position

**What's missing:** A visual representation. Currently, this data is only rendered as text or sent to the LLM.

---

## What's Already Being Captured

### 1. Stack Frames (`self.stack`)

Every frame in the call stack contains:
```python
frame = (frame_object, line_number)

# frame_object includes:
- f_code.co_filename  # File path
- f_code.co_name      # Function name
- f_lineno            # Current line number
- f_locals            # Local variables dict
- f_globals           # Global variables dict
```

### 2. Variable Values (All Types)

**Location:** [src/chatdbg/pdb_util/locals.py:145-172](src/chatdbg/pdb_util/locals.py#L145-L172)

For each frame, `print_locals()` captures:
- Variable names
- Type information (`type(value).__name__`)
- Formatted values (with smart truncation for large objects)
- Handles: lists, dicts, tuples, numpy arrays, custom objects

**Example output:**
```
Variables in this frame:
  a: int = 10
  b: int = 0
  items: list = [1, 2, 3, 4, 5]
  result: NoneType = None
```

### 3. Enriched Stack Trace

**Location:** [src/chatdbg/chatdbg_pdb.py:154-162](src/chatdbg/chatdbg_pdb.py#L154-L162)

The `enriched_stack_trace()` method generates a complete stack dump with:
- All frames in the call hierarchy
- Source code context (configurable lines)
- Variable values for each frame
- Current frame indicator (`>`)

**Example output:**
```
  File "script.py", line 25, in <module>
    result = divide_numbers(10, 0)
    Variables in this frame:
      result: NoneType = None

> File "script.py", line 6, in divide_numbers
    return a / b
    Variables in this frame:
      a: int = 10
      b: int = 0
```

### 4. Source Code Context

**Location:** [src/chatdbg/chatdbg_pdb.py:475-514](src/chatdbg/chatdbg_pdb.py#L475-L514)

`print_stack_trace()` includes configurable lines of source code around each frame.

### 5. Frame Filtering

The system already distinguishes:
- User code vs. library code
- Hidden frames (IPython internals)
- Current frame position

---

## Visualization Opportunities

### Option 1: Interactive Terminal UI (TUI)

Use libraries like `rich`, `textual`, or `urwid` to create an interactive terminal interface.

**Layout:**
```
┌─────────────────────────────────────────────────────────────┐
│ Stack Trace (Navigate with ↑/↓)                            │
├─────────────────────────────────────────────────────────────┤
│ ▶ divide_numbers (script.py:6)                             │
│   ├─ a: int = 10                                           │
│   └─ b: int = 0  ⚠️ Division by zero                       │
│                                                             │
│   <module> (script.py:25)                                  │
│   ├─ result: NoneType = None                               │
│   └─ [Called divide_numbers with (10, 0)]                  │
├─────────────────────────────────────────────────────────────┤
│ Source Code                                                 │
├─────────────────────────────────────────────────────────────┤
│   4  def divide_numbers(a, b):                             │
│   5      """Divide two numbers"""                          │
│ ▶ 6      return a / b                                      │
│   7                                                         │
│   8  # Call the function                                   │
├─────────────────────────────────────────────────────────────┤
│ Variable Details (Selected: b)                             │
├─────────────────────────────────────────────────────────────┤
│ Name:  b                                                    │
│ Type:  int                                                  │
│ Value: 0                                                    │
│ Set at: Line 25 (caller frame)                             │
└─────────────────────────────────────────────────────────────┘
```

**Features:**
- Navigate stack frames with arrow keys
- Click/select variables to see details
- Highlight problematic values
- Show variable history (where it was assigned)

### Option 2: Web-Based Visualization

Generate an HTML file with interactive JavaScript visualization.

**Features:**
- Call graph diagram (nodes = functions, edges = calls)
- Timeline showing execution order
- Variable mutation tracker
- Clickable elements for detail views
- Export as standalone HTML

**Technology stack:**
- D3.js for call graph visualization
- CodeMirror for syntax-highlighted source
- JSON data export from ChatDBG

### Option 3: ASCII Art Visualization (Terminal-friendly)

Simple tree-based visualization using box-drawing characters.

**Example:**
```
Call Stack (Top → Bottom)
│
├─ <module> (script.py:25)
│  │  Variables: result=None
│  │
│  └─→ divide_numbers(10, 0)
│
└─ divide_numbers (script.py:6) ❌ ZeroDivisionError
   │  Variables: a=10, b=0 ⚠️
   │  Line: return a / b
   └─ Problem: b is zero
```

### Option 4: Time-Travel Debugging Visualization

Show how variables changed as execution progressed.

**Example:**
```
Frame: <module>
┌─────────┬──────────┬──────────┬──────────┐
│ Line    │ result   │ Action   │ Notes    │
├─────────┼──────────┼──────────┼──────────┤
│ 24      │ None     │ Init     │          │
│ 25      │ ?        │ Call fn  │ → divide │
│ 25      │ None     │ Crash!   │ ❌       │
└─────────┴──────────┴──────────┴──────────┘

Frame: divide_numbers
┌─────────┬──────────┬──────────┬──────────┐
│ Line    │ a        │ b        │ Action   │
├─────────┼──────────┼──────────┼──────────┤
│ 6 entry │ 10       │ 0        │ Args in  │
│ 6       │ 10       │ 0        │ Divide   │
│ 6       │ 10       │ 0        │ ❌ Error │
└─────────┴──────────┴──────────┴──────────┘
```

---

## Implementation Strategy

### Phase 1: Data Export (Easy - 1-2 hours)

Create a structured data format for visualization.

**Add to [src/chatdbg/chatdbg_pdb.py](src/chatdbg/chatdbg_pdb.py):**

```python
def export_stack_data(self) -> dict:
    """Export stack trace data in structured format for visualization"""
    frames_data = []

    for idx, (frame, lineno) in enumerate(self.stack):
        # Get source code context
        source_lines = []
        try:
            import linecache
            filename = frame.f_code.co_filename
            for i in range(max(1, lineno - 5), lineno + 6):
                line = linecache.getline(filename, i)
                source_lines.append({
                    "line_num": i,
                    "content": line.rstrip(),
                    "is_current": i == lineno
                })
        except:
            pass

        # Get variables
        from chatdbg.pdb_util.locals import _extract_locals, _format_limited
        locals_dict = frame.f_locals
        defined_locals = _extract_locals(frame)
        variables = {}
        for name in defined_locals:
            value = locals_dict[name]
            variables[name] = {
                "type": type(value).__name__,
                "value": _format_limited(value, limit=20),
                "repr": repr(value)[:100]
            }

        frame_data = {
            "index": idx,
            "filename": frame.f_code.co_filename,
            "function": frame.f_code.co_name,
            "line_number": lineno,
            "is_current": idx == self.curindex,
            "is_user_code": self._is_user_file(frame.f_code.co_filename),
            "source_lines": source_lines,
            "variables": variables
        }
        frames_data.append(frame_data)

    return {
        "frames": frames_data,
        "error_message": self._error_message,
        "error_details": self._error_details,
        "timestamp": time.time()
    }
```

**Add a command:**
```python
def do_export(self, arg):
    """export [filename]
    Export stack trace data as JSON for visualization
    """
    import json
    filename = arg.strip() or "stack_trace.json"
    data = self.export_stack_data()
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    self.message(f"Exported stack data to {filename}")
```

**Usage:**
```
(ChatDBG) export my_crash.json
```

### Phase 2: Terminal UI Visualization (Medium - 1 day)

Use `textual` (modern TUI framework by the creator of `rich`).

**Create [src/chatdbg/ui/stack_viewer.py](src/chatdbg/ui/stack_viewer.py):**

```python
from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.widgets import Header, Footer, Tree, Static, DataTable
from rich.syntax import Syntax

class StackTraceViewer(App):
    """Interactive TUI for viewing stack traces"""

    CSS = """
    #stack-tree {
        width: 1fr;
        height: 100%;
        border: solid green;
    }

    #source-view {
        width: 2fr;
        height: 2fr;
        border: solid blue;
    }

    #variables-table {
        width: 2fr;
        height: 1fr;
        border: solid yellow;
    }
    """

    def __init__(self, stack_data: dict):
        super().__init__()
        self.stack_data = stack_data
        self.current_frame_idx = 0

    def compose(self) -> ComposeResult:
        yield Header()
        with Horizontal():
            yield Tree("Stack Trace", id="stack-tree")
            with Vertical():
                yield Static(id="source-view")
                yield DataTable(id="variables-table")
        yield Footer()

    def on_mount(self) -> None:
        # Populate the stack tree
        tree = self.query_one("#stack-tree", Tree)
        for frame in self.stack_data["frames"]:
            label = f"{frame['function']} ({frame['filename']}:{frame['line_number']})"
            if frame['is_current']:
                label = f"▶ {label}"
            tree.root.add_leaf(label)

        # Show initial frame
        self.show_frame(0)

    def show_frame(self, idx: int):
        frame = self.stack_data["frames"][idx]

        # Update source view
        source_widget = self.query_one("#source-view", Static)
        source_lines = "\n".join([
            f"{'▶' if line['is_current'] else ' '} {line['line_num']:4d} | {line['content']}"
            for line in frame['source_lines']
        ])
        syntax = Syntax(source_lines, "python", line_numbers=False)
        source_widget.update(syntax)

        # Update variables table
        table = self.query_one("#variables-table", DataTable)
        table.clear()
        table.add_columns("Name", "Type", "Value")
        for name, info in frame['variables'].items():
            table.add_row(name, info['type'], info['value'])

# Entry point
def view_stack_trace(json_file: str):
    import json
    with open(json_file) as f:
        data = json.load(f)
    app = StackTraceViewer(data)
    app.run()
```

**Add command:**
```python
def do_visualize(self, arg):
    """visualize
    Open interactive TUI visualization of stack trace
    """
    import tempfile
    import json
    from chatdbg.ui.stack_viewer import view_stack_trace

    # Export data to temp file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(self.export_stack_data(), f)
        temp_file = f.name

    # Launch TUI (blocks until closed)
    view_stack_trace(temp_file)

    # Clean up
    os.unlink(temp_file)
```

**Usage:**
```
(ChatDBG) visualize
```

Opens interactive TUI!

### Phase 3: Web-Based Visualization (Hard - 2-3 days)

**Create [src/chatdbg/ui/web_visualizer.py](src/chatdbg/ui/web_visualizer.py):**

Generate a standalone HTML file with:
- Call graph using D3.js
- Interactive source viewer
- Variable inspector
- Timeline view

```python
def generate_html_visualization(stack_data: dict, output_file: str):
    """Generate standalone HTML visualization"""

    html_template = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>ChatDBG Stack Trace Visualization</title>
        <script src="https://d3js.org/d3.v7.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.js"></script>
        <style>
            body { font-family: Arial, sans-serif; margin: 0; }
            #container { display: flex; height: 100vh; }
            #call-graph { width: 30%; border-right: 1px solid #ccc; }
            #details { width: 70%; padding: 20px; overflow-y: auto; }
            .frame-node { cursor: pointer; }
            .frame-node.current { stroke: red; stroke-width: 3px; }
            .variable { padding: 5px; margin: 5px 0; background: #f0f0f0; }
            .source-line { font-family: monospace; }
            .source-line.current { background: #ffeb3b; font-weight: bold; }
        </style>
    </head>
    <body>
        <div id="container">
            <div id="call-graph">
                <h2>Call Stack</h2>
                <svg id="graph-svg"></svg>
            </div>
            <div id="details">
                <div id="source-view"></div>
                <div id="variables-view"></div>
            </div>
        </div>

        <script>
            const stackData = STACK_DATA_PLACEHOLDER;

            // D3.js visualization code here
            // ... render call graph ...
            // ... interactive source viewer ...
            // ... variable inspector ...
        </script>
    </body>
    </html>
    """

    # Inject data
    html = html_template.replace(
        'STACK_DATA_PLACEHOLDER',
        json.dumps(stack_data)
    )

    with open(output_file, 'w') as f:
        f.write(html)

    print(f"Generated visualization: {output_file}")

    # Auto-open in browser
    import webbrowser
    webbrowser.open(f"file://{os.path.abspath(output_file)}")
```

**Usage:**
```
(ChatDBG) visualize --web
```

Opens browser with interactive visualization!

### Phase 4: LLM-Enhanced Visualization (Advanced)

Add AI annotations to the visualization:

```python
def add_ai_annotations(self, stack_data: dict) -> dict:
    """Ask LLM to annotate the stack trace with insights"""

    # Build prompt for LLM
    prompt = f"""
    Analyze this stack trace and annotate each frame with:
    1. What went wrong at this frame?
    2. Which variables are suspicious?
    3. Suggested fixes

    Stack data:
    {json.dumps(stack_data, indent=2)}

    Return JSON with annotations for each frame.
    """

    # Query LLM
    annotations = self._assistant.query(prompt, "annotate")

    # Merge annotations into stack data
    # ... merge logic ...

    return annotated_stack_data
```

Now visualizations include AI insights overlaid!

---

## Recommended Implementation Order

1. **Start with Phase 1 (Data Export)** ✅ Easy win
   - Adds `export` command
   - Creates JSON format
   - No UI complexity

2. **Add Phase 2 (Terminal UI)** ✅ High value
   - Uses existing `rich` dependency
   - Works in terminal (consistent with ChatDBG)
   - Good for quick debugging

3. **Consider Phase 3 (Web UI)** ⚠️ Optional
   - More complex
   - Better for presentations/sharing
   - Requires web development

4. **Experiment with Phase 4 (AI Annotations)** 🔬 Research
   - Most innovative
   - Combines ChatDBG's strengths
   - Could be a killer feature

---

## Example: Complete Flow

```bash
$ chatdbg -c continue test_chatdbg.py

# Program crashes...

(ChatDBG) export crash.json
Exported stack data to crash.json

(ChatDBG) visualize
# Opens interactive TUI

# Navigate with arrow keys:
# - Up/Down: Change frame
# - Enter: See variable details
# - Q: Quit back to debugger

(ChatDBG) why
# Traditional AI explanation

(ChatDBG) visualize --web crash.html
# Opens browser with interactive visualization
# Can share crash.html with team!
```

---

## Benefits of Stack Visualization

### 1. **Visual Debugging**
- See entire call hierarchy at once
- Spot patterns in variable values
- Understand execution flow quickly

### 2. **Educational**
- Great for teaching debugging
- Shows how stack frames work
- Visualizes variable scope

### 3. **Team Collaboration**
- Export visualizations to share
- Non-technical stakeholders can understand
- Better bug reports

### 4. **Integration with AI**
- LLM can reference specific frames: "Look at frame 2"
- Visual context for AI explanations
- Annotated visualizations with AI insights

---

## Technical Requirements

### Dependencies

**For Terminal UI:**
```toml
dependencies = [
    # ... existing ...
    "textual>=0.40.0",  # Modern TUI framework
]
```

**For Web UI:**
```toml
dependencies = [
    # ... existing ...
    "jinja2>=3.0.0",  # HTML templating
]
```

### File Structure

```
src/chatdbg/
├── ui/
│   ├── __init__.py
│   ├── stack_viewer.py      # Terminal UI
│   ├── web_generator.py     # Web visualization generator
│   └── templates/
│       └── stack_trace.html # HTML template
└── util/
    └── export.py            # Data export utilities
```

---

## Next Steps

1. **Proof of Concept:** Implement Phase 1 (data export) first
2. **User Testing:** Get feedback on what visualizations would be most useful
3. **Iterate:** Start with simple ASCII art, then add richer UIs
4. **Integration:** Make visualization a natural part of the ChatDBG workflow

---

## Conclusion

**ChatDBG has ALL the data needed for rich stack trace visualization!** The missing piece is just the UI layer. With relatively little effort, you could add:

- Interactive terminal UI for exploring stack traces
- Exportable JSON data for custom tools
- Web-based visualizations for sharing
- AI-annotated diagrams showing root causes

This would make ChatDBG even more powerful, combining:
- **Traditional debugging** (pdb commands)
- **AI assistance** (LLM explanations)
- **Visual exploration** (stack trace visualization)

A true next-generation debugging tool! 🚀
