# Name of this Lambda (used for the .zip file name)
PACKAGE_NAME=fruit-api-PATCH
ZIP_FILE=../$(PACKAGE_NAME).zip

# Default target
all: clean deps package

# Clean up old zip
clean:
	rm -f $(ZIP_FILE)

# Install deps from shared app root
deps:
	cd ../../ && npm ci --omit=dev
	cp -r ../../node_modules .

# Create deployment package
package: clean deps
	zip -r $(ZIP_FILE) . \
		-x "*.git*" \
		-x "*.DS_Store" \
		-x "package-lock.json" \
		-x "package.json" \
		-x "Makefile"

.PHONY: all clean deps package
