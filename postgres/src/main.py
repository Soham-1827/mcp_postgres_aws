# main.py - Entry point for MCP Server

import os
import sys
from pathlib import Path

# Add src directory to Python path
sys.path.insert(0, str(Path(__file__).resolve().parent))

from dotenv import load_dotenv
load_dotenv()

from v1.server import create_server
from mcp.server.fastmcp import FastMCP

if __name__ == "__main__":
    mcp = FastMCP("PostgreSQL MCP Server")
    
    server = create_server(mcp)
    print("Starting PostgreSQL MCP Server for Claude...")
    print("Server will run at: http://localhost:8000")
    print("\nTo use with Claude Desktop:")
    print("1. Add to Claude's MCP settings")
    print("2. Server type: HTTP")
    print("3. URL: http://localhost:8000/mcp")
    
    # Run the server
    mcp.run(transport="streamable-http")
