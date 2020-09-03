// SPDX-License-Identifier: MIT
const fs = require("fs");
const path = require("path");
const md2json = require("md-2-json");

const walkSync = (dir) => {
  let filelist = [];
  fs.readdirSync(dir).forEach((file) => {
    filelist = fs.statSync(path.join(dir, file)).isDirectory()
      ? walkSync(path.join(dir, file), filelist)
      : filelist.concat(path.join(dir, file));
  });
  return filelist;
};

const command = process.argv[2];

const generateDeFiSEC = () => {
  const files = walkSync("../catalog");
  const result = {};

  files.map((file) => {
    const content = fs.readFileSync(file, "utf8");
    const parsed = md2json.parse(content);
    const [name] = /(DeFiSEC)-[0-9]+/.exec(file);
    const root = parsed.Title;
    try {
      result[name] = {
        markdown: content,
        content: {
          Title: root.raw.trim(),
          Relationships: root.Relationships.raw.trim(),
          Description: root.Description.raw.trim(),
          Remediation: root.Remediation.raw.trim(),
        },
      };
    } catch (e) {
      console.log(
        ` <!> Wrong document format: ${name}.md, provide content for all required headings`
      );
      console.log(e);
      if (command && command === "markdown-validate") {
        process.exit(1);
      }
    }
  });
  return result;
};

const defisec = generateDeFiSEC();

if (!command || command !== "markdown-validate") {
  console.log(JSON.stringify(defisec, null, 2));
}
// Return 0 status code
process.exit();
