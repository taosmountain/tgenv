test:
	./test/run.sh

update-changelog:
	auto-changelog

update-toc:
	doctoc --maxlevel 2 ./README.md

update: update-changelog update-toc
