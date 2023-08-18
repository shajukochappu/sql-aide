import {
  Directory,
  File,
  FileSystem,
  FileSystemEntry,
  MutableDirectory,
  MutableFile,
} from "./governance.ts";
import { Content, TextContent } from "./content.ts";

export type LocalFsEntry = FileSystemEntry<string>;

export class LocalFile
  implements
    File<LocalFsEntry, Uint8Array>,
    Content<LocalFsEntry>,
    TextContent<LocalFsEntry> {
  constructor(readonly fsEntry: LocalFsEntry) {
  }

  async readable() {
    const fsFile = await Deno.open(this.fsEntry.canonicalPath, {
      read: true,
    });
    return fsFile.readable;
  }

  async content(): Promise<Uint8Array> {
    return await Deno.readFile(this.fsEntry.canonicalPath);
  }

  async text(): Promise<string> {
    return await Deno.readTextFile(this.fsEntry.canonicalPath);
  }
}

export class LocalMutableFile extends LocalFile
  implements MutableFile<LocalFsEntry, Uint8Array> {
  async writable() {
    const fsFile = await Deno.open(this.fsEntry.canonicalPath, {
      write: true,
      create: true,
    });
    return fsFile.writable;
  }
}

// ... (rest of the code remains unchanged)
export class LocalDirectory implements Directory<LocalFsEntry, LocalFile> {
  constructor(readonly fsEntry: LocalFsEntry) {
  }

  async *files<Content extends LocalFile>(
    options?: Parameters<Directory<LocalFsEntry, Content>["files"]>[0],
  ): AsyncGenerator<Content> {
    for await (const dirEntry of Deno.readDir(this.fsEntry.canonicalPath)) {
      if (dirEntry.isFile) {
        let file = new LocalFile({ canonicalPath: dirEntry.name }) as Content;
        if (options?.factory) {
          file = options.factory(file as Content);
        }
        if (!options?.filter) {
          yield file;
        } else {
          const result = options.filter(file);
          if (result !== false) yield result;
        }
      }
    }
  }

  async *subdirectories(
    options?: Parameters<
      Directory<LocalFsEntry, LocalFile>["subdirectories"]
    >[0],
  ): AsyncGenerator<LocalDirectory> {
    for await (const dirEntry of Deno.readDir(this.fsEntry.canonicalPath)) {
      if (dirEntry.isDirectory) {
        let dir = new LocalDirectory({ canonicalPath: dirEntry.name });
        if (options?.factory) dir = options.factory(dir);
        if (!options?.filter) {
          yield dir;
        } else {
          const result = options.filter(dir);
          if (result !== false) yield result;
        }
      }
    }
  }

  async *entries(
    options?: Parameters<Directory<LocalFsEntry, LocalFile>["entries"]>[0],
  ): AsyncGenerator<LocalFile | LocalDirectory> {
    for await (const dirEntry of Deno.readDir(this.fsEntry.canonicalPath)) {
      const fsEntry: LocalFsEntry = { canonicalPath: dirEntry.name };
      let entry: LocalFile | LocalDirectory;
      if (dirEntry.isFile) {
        entry = new LocalFile(fsEntry);
      } else {
        entry = new LocalDirectory(fsEntry);
      }
      const instance = options?.factory ? options.factory(entry) : entry;
      if (!options?.filter) {
        yield instance;
      } else {
        const result = options.filter(instance);
        if (result !== false) yield result;
      }
    }
  }
}

export class LocalMutableDirectory extends LocalDirectory
  implements MutableDirectory<LocalFsEntry, LocalFile> {
  private bufferSize: number;

  constructor(fsEntry: LocalFsEntry, bufferSize?: number) {
    super(fsEntry);
    this.bufferSize = bufferSize || 4096; // Default to 4KB if not provided
  }

  async add(
    entry: LocalFile | LocalDirectory,
  ): Promise<boolean | number> {
    if (entry instanceof LocalFile) {
      try {
        // Check if the file already exists
        await Deno.stat(entry.fsEntry.canonicalPath);
        return false; // File already exists
      } catch (error) {
        if (error instanceof Deno.errors.NotFound) {
          // Create the file using streaming
          const destFile = await Deno.open(entry.fsEntry.canonicalPath, {
            write: true,
            create: true,
          });
          const srcStream = await entry.readable();
          srcStream.pipeTo(destFile.writable);
          destFile.close();

          return true; // File created and written to successfully
        }
        throw error; // Rethrow other errors
      }
    } else if (entry instanceof LocalDirectory) {
      try {
        // Check if the directory already exists
        await Deno.stat(entry.fsEntry.canonicalPath);
        return false; // Directory already exists
      } catch (error) {
        if (error instanceof Deno.errors.NotFound) {
          // Create the directory if it doesn't exist
          await Deno.mkdir(entry.fsEntry.canonicalPath);
          return true; // Directory created successfully
        }
        throw error; // Rethrow other errors
      }
    } else {
      throw new Error("Unsupported entry type");
    }
  }
}

export class LocalFileSystem
  implements FileSystem<LocalFsEntry, LocalFile, LocalDirectory> {
  file(path: LocalFsEntry): LocalFile {
    return new LocalFile(path);
  }

  directory(
    path: LocalFsEntry = { canonicalPath: Deno.cwd() },
  ): LocalDirectory {
    return new LocalDirectory(path);
  }
}
