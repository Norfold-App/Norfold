# Norfold Note/Notes to Doc/Docs Migration Contract

**Stage:** Started, compatibility-first  
**Automation:** `scripts/migrate_note_terms.py`

## What changed

The first automated phase renamed high-level Kotlin architecture and approved UI copy:

- `NotesUiState` → `DocsUiState`
- `NotesViewModel` → `DocsViewModel`
- `NotesRepository` → `DocsRepository`
- `NotesScreen` → `DocsScreen`
- Exact approved labels such as `Notes`, `All notes`, and `New note` → their Docs equivalents

The script defaults to dry-run, writes atomically only with `--apply`, is idempotent, and refuses a transformation that changes protected storage/sync literal counts.

```bash
python3 scripts/migrate_note_terms.py --phase all
python3 scripts/migrate_note_terms.py --phase all --apply
```

## Protected compatibility seams

Do not rename these merely for terminology consistency:

- Room table names such as `notes`, `note_blocks`, and `note_embeds`
- Persisted columns such as `noteId`
- Backup record discriminator `NOTE`
- Sync/shared-object type literal `note`
- Existing exported Room schemas and old encrypted snapshot formats

Class filenames and database/entity/DAO names may temporarily retain Notes/Note wording. Rename them only in a separate compile-tested phase with explicit adapter/serialization proof; cosmetic churn is not worth breaking restores.

## Next safe phases

1. Rename the domain authoring object `Note` to `Doc` with a temporary source-compatible alias.
2. Rename public creation/update commands (`createNote`, `updateNote`) after all call sites and analytics/activity labels are classified.
3. Rename files to match the new symbols after imports are stable.
4. Remove temporary aliases only after grep, unit, instrumentation, backup/restore, and sync fixture proof.

Every phase must run the codemod dry-run, unit tests, debug build, current-schema backup round trip, and an emulator create/edit/reopen path. The Beta gate does not permit persisted-contract renaming without migrations and distributed-version fixtures.
