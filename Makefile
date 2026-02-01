main:
	@odin build . -debug -out:"Mask Tactics.exe" -export-dependencies:json -export-dependencies-file:"dependencies.d"
	@"./Mask Tactics.exe"

release:
	@odin build . -out:"Mask Tactics.exe" -subsystem:windows