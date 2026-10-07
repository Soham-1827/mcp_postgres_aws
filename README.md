# PostgreSQL MCP Server

[![GitHub Repo stars](https://img.shields.io/github/stars/Soham-1827/mcp_postgres_aws?style=social)](https://github.com/Soham-1827/mcp_postgres_aws)

---

**Author:** Soham Rajesh Choulwar
Goated project before MCP was something
---

This project is a complete starter kit for running a **Model Context Protocol (MCP) server** with a PostgreSQL database backend. It’s designed for building and testing AI-powered research agents, tools, and workflows that need a flexible SQL backend. You also get a sample e-commerce schema with test data, and everything can be deployed to the cloud using Terraform.

## 🌟 What is this project?
- Future work on JSONB files and super large json files

- **MCP Server:** Lets you connect your AI tools (like Claude Desktop) or custom workflows to a PostgreSQL database, through a robust, API-driven server.
- **Sample Database:** Includes ready-to-use tables (users, products, orders) for quick experimentation.
- **Cloud Ready:** Use Terraform to easily deploy your whole stack to AWS or any cloud provider.

---

## 🛠️ Step-by-step Setup Guide

### 1. **Clone the repository**

Start by copying the project to your computer:
bash
```
git clone https://github.com/Soham-1827/mcp_postgres_aws.git
cd mcp_postgres_aws
```

2. Set up Python and dependencies
bash
```
Create a virtual environment (recommended):


python -m venv venv
source venv/bin/activate       # On Windows: venv\Scripts\activate
Install the required Python packages:


pip install -r requirements.txt
```

3. Add your environment variables
bash
```
Inside postgres/src/, create a file called .env:


DB_HOST=your-db-endpoint
DB_USER=postgres
DB_PASS=your-password
DB_NAME=postgres
SECRET_ID=your-secret-id
DEBUG=true
These settings tell the server how to connect to your database.
Never commit .env to GitHub!
```

4. Set up the database
bash
```
From the postgres/src/ folder, run:


python init_db.py
This will read the provided scripts/init_database.sql and create all tables and test data for you.
```

5. Run the MCP Server
bash
```
To start the HTTP server (good for API access/testing):



python main.py
The server will be available at http://localhost:8000.

To run in STDIO mode (for tools like Claude Desktop):


python run_stdio.py
```
🧩 Features
Easy AI Integration: Serve data and schemas to LLMs, AI agents, or custom dashboards.

Custom Tools: Out-of-the-box endpoints for getting table data, schemas, and running queries.

Cloud Ready: Use the terraform/ folder to spin up all resources on AWS in a few commands.

📚 Project Structure
```
.
├── terraform/              # Terraform scripts for AWS/cloud setup
├── postgres/
│   └── src/
│       ├── connection.py   # Database connection logic
│       ├── init_db.py      # One-time setup: loads tables/data
│       ├── main.py         # Starts HTTP MCP server
│       ├── run_stdio.py    # STDIO mode (Claude Desktop)
│       ├── server.py       # MCP server logic/tools
│       └── ...             # Other modules
├── scripts/
│   └── init_database.sql   # SQL schema/data for e-commerce demo
├── .gitignore
└── README.md
```
💬 Need help?
Open an issue on the GitHub repo if you get stuck or have questions!

⭐️ Like this project?
Star it on GitHub if it helped you, or share with friends!
