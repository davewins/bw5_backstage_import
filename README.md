# TIBCO BW5 to Backstage Automated Inventory

This project provides a high-fidelity extraction engine that converts legacy TIBCO BusinessWorks 5.x deployment artifacts (.ear files) into a modern, searchable **Backstage Software Catalog**. 

It automates the discovery of internal processes, shared libraries, and infrastructure dependencies, providing visual architecture diagrams (Mermaid) and responsive TechDocs for every application.

---

## 📂 Repository Structure

* **/apps**: Contains a folder for every processed EAR file. Each includes:
    * `catalog-info.yaml`: The Backstage Component definition.
    * `mkdocs.yml`: Documentation configuration.
    * `/docs`: Automated architectural documentation.
* **/libs**: Contains unique, project-scoped **Shared Archives (.sar)**.
* **/resources**: Global infrastructure entities like JDBC databases and JMS endpoints.
* `catalog-info.yaml`: The root entry point for the TIBCO Developer Hub.

---

## 🚀 Usage

### 1. Prerequisites
* **TIBCO TRA**: Must be installed on the machine running the script.
* **Permissions**: Ensure the user has read/write access to the `./ears` and `./bw5-inventory` directories.
* **Environment**: Set the `TRA_HOME` environment variable:
    ```bash
    export TRA_HOME=/opt/tibco/tra/5.x
    ```

### 2. Execution
Place your `.ear` files in the `./ears` directory and run the main sync script:

```bash
./bw5_to_backstage_ultimate.sh --verbose --push
