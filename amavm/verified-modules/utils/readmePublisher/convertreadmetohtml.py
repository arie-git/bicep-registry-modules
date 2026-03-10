# This script is used to convert module's README.md file to html

# It reads MD files from under the 'bicep' directory in the repository
# Then it uses the markdown2 library to convert them to HTML
# It uses an HTML page template and saves complete HTML pages files under the 'utils/html-assets/readmePublisher/docs' folder
# It also updates the menu (with list of available modules and versions) in the 'utils/html-assets/readmePublisher/menu/toc.json' file

import markdown2
import os
from pathlib import Path
import json
import argparse
import re

def get_static_html_layout(file_path: str):
    # Read the contents of the file
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

# Read the JSON file
def read_json_file(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

# Write to the JSON file
def write_json_file(file_path, data):
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

def main():

    # Create the argument parser
    parser = argparse.ArgumentParser(description="Generate HTML representation of the documentation.")
    parser.add_argument(
        "--sources-root-path",
        type=str,
        default=f"{os.path.dirname(os.path.abspath(__file__))}/../../bicep/",
        required=False,
        help="Path to the bicep sources root directory. Should always point to the root.",
    )
    parser.add_argument(
        "--sources-subpath",
        type=str,
        default="",
        required=False,
        help="Path to the modules relative to sources-root-path. When empty will include all modules in the repository."
    )
    parser.add_argument(
        "--template-path",
        type=str,
        default=f"{os.path.dirname(os.path.abspath(__file__))}/../html-assets/readmePublisher",
        required=False,
        help="Path to the HTML templates."
    )
    parser.add_argument(
        "--generate-toc",
        action='store_true',
        help="Should the script update the TOC file. Default: false"
    )

    # Parse the arguments
    args = parser.parse_args()

    # Get file paths from arguments
    sources_root_path = args.sources_root_path
    template_path = args.template_path
    sources_subpath = args.sources_subpath
    generate_toc = args.generate_toc

    # Resolve file paths, and test for their existance
    sources_root_directory = Path(sources_root_path).resolve()
    source_subdirectory = sources_root_directory.joinpath(sources_subpath).resolve()
    destination_file_path = Path(template_path).resolve()
    for path in [sources_root_directory, source_subdirectory, destination_file_path]:
        if not path.exists():
            print(f"Error: The path '{path}' does not exist.")
            exit(1)


    # Find all .md files in the sources directory recursively
    md_files = list(source_subdirectory.rglob("*.md"))

    # Print the paths of the .md files
    if md_files:
        print(f"Found {len(md_files)} Markdown files:\n")
    else:
        print(f"No Markdown files found in {source_subdirectory}.")
        exit(0)

    # Get HTML layout for the module
    html_layout = get_static_html_layout(f"{destination_file_path}/placeholder.html")
    for md_file_path in md_files:
        html_contents = ""
        # Check if the version.json file exists that identifies module's version
        module_version_file_path = os.path.join(os.path.dirname(md_file_path), 'version.json')
        if not os.path.exists(module_version_file_path):
            print(f"File [{module_version_file_path}] does not exist. Not a module. Skipping...")
            continue

        # Get the current version — ensure exactly 3 segments (major.minor.patch)
        raw_version: str = read_json_file(module_version_file_path)['version']
        version_parts = raw_version.split(".")
        while len(version_parts) < 3:
            version_parts.append("0")
        module_version: str = ".".join(version_parts[:3])
        module_page_id: str = module_version.replace(".","-")

        # Get the contents of Markdown README file
        with open(md_file_path, "r") as readme_file:
            md_file_contents = readme_file.read()

        # HTML file will be saved under module/version path
        module_relative_path = (
            str(md_file_path.parent.resolve())
            .replace(str(sources_root_directory.resolve()), "")
            .removeprefix("/")
            .removeprefix("\\")
        )

        # Get contents of the TOC file
        toc_file_path = os.path.join(destination_file_path, "menu", "toc.json")
        # Read toc json (either a template of an existing toc)
        toc_contents = read_json_file(toc_file_path)
        # Ensure data is a list
        if not isinstance(toc_contents, list):
            raise ValueError("JSON data is not a list")
        # Find versions of the current module
        output_module_id = module_relative_path.replace("/","-").replace("\\","-")
        current_module_toc_item = next((item for item in toc_contents if item["id"] == output_module_id), None)
        item_other_versions_html = ""
        if current_module_toc_item is not None:
            item_other_versions_html = "Other versions: "
            if not isinstance(current_module_toc_item.get("versions"), list):
                raise ValueError("versions data is not a list")
            for item_version in current_module_toc_item.get("versions"):
                if not isinstance(item_version, dict):
                    raise ValueError("version data is not a dict")
                if item_version.get("version") != module_version:
                    item_other_versions_html += f"<a href=\"{item_version['page']}\">{item_version['version']}</a>&nbsp;&nbsp;"
            if item_other_versions_html == "Other versions: ":
                item_other_versions_html = ""
        html_contents += f"<p>Version <a href=\"{module_page_id}.html\">{module_version}</a>&nbsp;&nbsp;&nbsp;&nbsp;{item_other_versions_html}</p>"

        # Print path to module in the registry
        module_registry_path = module_relative_path.replace("\\","/")
        html_contents += f"<br/><p>{module_registry_path}:{module_version}</p>"

        # Convert Markdown to HTML
        # item_other_versions_html
        raw_html = markdown2.markdown(md_file_contents,extras=["tables","toc","fenced-code-blocks"])
        # Fix heading IDs: markdown2 keeps underscores/special chars in id attributes (e.g. "example-1-_deploying_")
        # but setModuleReadMe.ps1 strips non-[A-Za-z0-9\s-] when generating anchor links (e.g. "#example-1-deploying").
        # Normalize heading IDs to match the link targets.
        def normalize_heading_id(match):
            prefix = match.group(1)
            raw_id = match.group(2)
            normalized = re.sub(r'[^a-z0-9\s-]', '', raw_id).strip()
            normalized = re.sub(r'\s+', '-', normalized)
            normalized = re.sub(r'-+', '-', normalized)
            return f'{prefix}id="{normalized}"'
        raw_html = re.sub(r'(<h[1-6]\s+)id="([^"]*)"', normalize_heading_id, raw_html)
        html_contents += raw_html

        # create the pages: one with version for the history, and an index.html with the current version
        for page_name in ["index", module_page_id]:
            #### create HTML pages
            output_file_name = page_name + ".html"
            output_file_path = os.path.join(destination_file_path, "docs", output_module_id, output_file_name)
            # create the complete file path if it doesn't exist
            os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
            # Get the full name of the module from the first line of the Markdown file
            first_line_match = re.search(r'#\s*(.*?)\s*`', md_file_contents.splitlines()[0])
            if first_line_match:
                module_full_name = first_line_match.group(1)
            else:
                # Fallback: use module path as name if README header doesn't match expected format
                module_full_name = module_relative_path.replace("/", " / ").replace("-", " ").title()
                print(f"  Warning: Could not parse module name from README header in {md_file_path}. Using fallback: {module_full_name}")
            
            # Now perform all replacements on the layout
            final_html = (
                html_layout
                .replace("{TITLE}", f"AMAVM Documentation - {module_full_name}")  # Replace the title placeholder
                .replace("{PLACEHOLDER}", html_contents)   # Replace the main content placeholder
                )
            with open(output_file_path,"w") as html_file:
                html_file.write(final_html)

            #### update the module index
            if generate_toc:

                # Define the version page information of the item
                new_item_version = {
                    "version" : module_version,
                    "page" : output_file_name
                }
                # Define an item to be appended the list, or updates to an existing item
                new_item = {
                    "text" : module_full_name,
                    "url" : f"/docs/{output_module_id}/{output_file_name}",
                    "id" : output_module_id,
                    "category" : "Other",
                    "versions" : [
                        new_item_version
                    ]
                }

                # If the module is already in TOC then update it, otherwise add it to TOC
                item_exists = any(item.get("id") == new_item["id"] for item in toc_contents)
                if not item_exists:
                    toc_contents.append(new_item)
                else:
                    for item in toc_contents:
                        if item.get("id") == new_item["id"]:
                            # Update url and menu text for the page
                            item["url"] = new_item["url"]
                            item["text"] = new_item["text"]
                            # Add the current version to the list if it doesn't exist yet, or update if it does
                            if item.get("versions","") != "":
                                existing_dict = {obj["version"]: obj for obj in item["versions"]}
                                existing_dict[new_item_version["version"]] = new_item_version
                                item["versions"] = list(existing_dict.values())
                            else:
                                item["versions"] = new_item["versions"]
                            break
                # Write the updated data back to the JSON file
                write_json_file(toc_file_path, toc_contents)

            # done
            print(f"{module_relative_path}/{output_file_name} created.")

    #end main()

if __name__ == '__main__':
    main()
