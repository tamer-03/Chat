import fs from "node:fs/promises";
import path from "node:path";
import { v4 as uuidv4 } from "uuid";

const defaultFolder = "storage";
const storageFolder = path.join(__dirname, "..", defaultFolder);
export const createFolderAsync = async (
  folderName: string
): Promise<boolean> => {
  try {
    const status = await checkFolderAsync(folderName);

    console.log("folder stat : " + status);

    if (status) {
      return Promise.resolve(true);
    } else {
      fs.mkdir(`${storageFolder}/${folderName}`);
      return Promise.resolve(true);
    }
  } catch (e) {
    return Promise.resolve(false);
  }
};

export const checkFolderAsync = async (
  folderName: string
): Promise<boolean> => {
  try {
    const targetPath = path.join(storageFolder, folderName);
    await fs.access(targetPath);
    return Promise.resolve(true);
  } catch (e) {
    return Promise.resolve(false);
  }
};

export const writeFileToFolderAsync = async (
  folderName: string,
  file: any[],
  fileSize: number = 1 * 1024 * 1024
) => {
  if (file.length <= 0) {
    return [];
  }

  const folderStatus = await checkFolderAsync(folderName);
  const fileNames: string[] = [];
  if (!folderStatus) {
    const createFolderStat = await createFolderAsync(folderName);
    if (!createFolderStat) {
      return [];
    }
  }


  await Promise.all(
    file.map(async (e) => {
      const generateUUID = uuidv4();
      const base64Data = e.replace(/^data:image\/(jpeg|png|jpg);base64,/, "");
      const buffer = Buffer.from(base64Data, "base64");

      if (buffer.length > fileSize) {
        console.log("Size is bigger than 1 MB:", buffer.length);
        return;
      }

      const fileExtension = e.startsWith("data:image/png") ? ".png" : ".jpeg";
      await fs.writeFile(
        `${storageFolder}/${folderName}/${generateUUID}${fileExtension}`,
        buffer
      );
      fileNames.push(`${generateUUID}${fileExtension}`);
    })
  );

  return fileNames;
};
