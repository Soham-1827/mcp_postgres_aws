#!/usr/bin/env python
"""Run the PostgreSQL MCP server with stdio transport for Claude Desktop."""

import sys
from pathlib import Path

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from dotenv import load_dotenv

load_dotenv()

from v1.server import create_server
from fastmcp import FastMCP

if __name__ == "__main__":
    # Create MCP instance
    mcp = FastMCP("PostgreSQL MCP Server")

    # Set up the server with our tools
    server = create_server(mcp)

    # Run with stdio transport for Claude Desktop
    mcp.run(transport="stdio")