GO111MODULE=on

.PHONY: build
build: gocron node

.PHONY: build-race
build-race: enable-race build

.PHONY: run
run: build kill
	./bin/gocron-node &
	./bin/gocron web -e dev

.PHONY: run-race
run-race: enable-race run

.PHONY: kill
kill:
	-killall gocron-node

.PHONY: gocron
gocron:
	go build $(RACE) -o bin/gocron ./cmd/gocron

.PHONY: node
node:
	go build $(RACE) -o bin/gocron-node ./cmd/node

.PHONY: test
test:
	go test $(RACE) ./...

.PHONY: test-race
test-race: enable-race test

.PHONY: enable-race
enable-race:
	$(eval RACE = -race)

.PHONY: package
package: build-vue copy-vue statik

.PHONY: package-all
package-all: build-vue copy-vue statik
	bash ./package.sh -p 'linux darwin windows'

.PHONY: build-vue
build-vue:
	cd web/vue && yarn run build

.PHONY: copy-vue
copy-vue:
ifeq ($(OS),Windows_NT)
	copy -r web/vue/dist/* web/public/
else
	cp -r web/vue/dist/* web/public/
endif	

.PHONY: install-vue
install-vue:
	cd web/vue && yarn install --ignore-engines

.PHONY: run-vue
run-vue:
	cd web/vue && yarn run dev

.PHONY: statik
statik:
	go install github.com/rakyll/statik@latest
	go generate ./...

.PHONY: lint
	golangci-lint run

.PHONY: clean
clean:
	rm bin/gocron
	rm bin/gocron-node
