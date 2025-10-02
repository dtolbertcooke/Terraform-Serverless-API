# Name of this Lambda (used for the .zip file name)
PACKAGE_NAME=fruit-api-GET
ZIP_FILE=../$(PACKAGE_NAME).zip

# Default target
all: clean install package

# Clean up old zip
clean:
	rm -f $(ZIP_FILE)

# Install only production deps (ignore devDependencies)
install:
	npm i --omit=dev

# Create deployment package
package: clean install
	zip -r $(ZIP_FILE) . \
		-x "*.git*" \
		-x "*.DS_Store" \
		-x "package-lock.json" \
		-x "package.json" \
		-x "Makefile"

# idk what this does
# .PHONY: all clean install package
