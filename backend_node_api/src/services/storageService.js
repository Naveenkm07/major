const { PutObjectCommand, GetObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const s3Client = require('../config/s3');
const config = require('../config');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

class StorageService {
    /**
     * Upload file to S3
     */
    async uploadFile(file, folder = 'uploads') {
        const ext = path.extname(file.originalname);
        const key = `${folder}/${uuidv4()}${ext}`;

        const command = new PutObjectCommand({
            Bucket: config.aws.s3Bucket,
            Key: key,
            Body: file.buffer,
            ContentType: file.mimetype,
        });

        await s3Client.send(command);
        return key;
    }

    /**
     * Get signed URL for downloading
     */
    async getSignedUrl(key, expiresIn = 3600) {
        const command = new GetObjectCommand({
            Bucket: config.aws.s3Bucket,
            Key: key,
        });

        return await getSignedUrl(s3Client, command, { expiresIn });
    }

    /**
     * Delete file from S3
     */
    async deleteFile(key) {
        const command = new DeleteObjectCommand({
            Bucket: config.aws.s3Bucket,
            Key: key,
        });

        await s3Client.send(command);
    }
}

module.exports = new StorageService();
