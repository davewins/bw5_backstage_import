# TIBCO BW5 to Backstage Automated Inventory

This project provides a high-fidelity extraction engine that converts legacy TIBCO BusinessWorks 5.x deployment artifacts (.ear files) into a modern, searchable **Backstage Software Catalog**. 

---

## 🚀 Deployment Modes

The application operates in two distinct modes depending on your requirements:

### 1. Local Generation Mode (Default)
If you run the script **without** the `--push` flag, it generates all Backstage `catalog-info.yaml` files, `mkdocs.yml` configurations, and Markdown documentation locally in the `./bw5-inventory` directory. This is ideal for verifying content before publishing.

### 2. Remote Sync Mode (`--push`)
When the `--push` flag is used, the application:
1.  Generates the complete repository structure locally.
2.  Automatically commits the changes with a timestamped message.
3.  Pushes the entire catalog to your configured GitHub repository.
4.  **Integration**: Once pushed, you can simply register the root `catalog-info.yaml` URL in **TIBCO Developer Hub** or any Backstage instance to import the entire estate at once.

---

## 📂 Repository Structure

* **/apps**: Component definitions and TechDocs for every EAR.
* **/libs**: Unique, project-scoped **Shared Archives (.sar)**.
* **/resources**: Discovered infrastructure (JDBC, JMS, etc.).
* `catalog-info.yaml`: The root entry point for mass-importing the inventory.

---

## ⚙️ Configuration

### Environment Variables
Required for TIBCO extraction and GitHub synchronization:

```bash
# TIBCO Configuration
export TRA_HOME=/opt/tibco/tra/5.x

# GitHub Configuration (Required for --push)
export GITHUB_USER="your-github-username"
export GITHUB_TOKEN="your-personal-access-token"
export GITHUB_REPO="bw5-inventory"
