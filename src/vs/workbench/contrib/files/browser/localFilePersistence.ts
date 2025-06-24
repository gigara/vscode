/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { IWorkbenchContribution } from '../../../common/contributions.js';
import { IFileService, FileOperation } from '../../../../platform/files/common/files.js';
import { IWorkspaceContextService } from '../../../../platform/workspace/common/workspace.js';
import { IModelService } from '../../../../editor/common/services/model.js';
import { VSBuffer } from '../../../../base/common/buffer.js';
import { URI } from '../../../../base/common/uri.js';

export class LocalFilePersistenceContribution implements IWorkbenchContribution {
	static readonly ID = 'workbench.contrib.localFilePersistence';

	private readonly prefix = 'devantEditor.localfile.';
	private readonly workspaceUris: URI[];

	constructor(
		@IFileService private readonly fileService: IFileService,
		@IWorkspaceContextService private readonly workspaceContextService: IWorkspaceContextService,
		@IModelService private readonly modelService: IModelService
	) {
		this.workspaceUris = this.workspaceContextService.getWorkspace().folders.map(f => f.uri);
		this.restoreFilesFromLocalStorage();
		this.subscribeToModelChanges();
		this.subscribeToFileOperations();
	}

	private isInWorkspace(uri: URI): boolean {
		return this.workspaceUris.some(folderUri => uri.toString().startsWith(folderUri.toString()));
	}

	private async restoreFilesFromLocalStorage() {
		for (let i = 0; i < localStorage.length; i++) {
			const key = localStorage.key(i);
			if (key && key.startsWith(this.prefix)) {
				const uriString = key.substring(this.prefix.length);
				try {
					const uri = URI.parse(uriString);
					if (this.isInWorkspace(uri)) {
						const content = localStorage.getItem(key);
						if (content !== null) {
							await this.fileService.writeFile(uri, VSBuffer.fromString(content));
						}
					}
				} catch (e) {
					// Ignore malformed URIs
					console.error('Failed to restore file from localStorage', key, e);
				}
			}
		}
	}

	private subscribeToModelChanges() {
		// Subscribe to all existing models
		for (const model of this.modelService.getModels()) {
			this.subscribeModel(model);
		}
		// Subscribe to new models
		this.modelService.onModelAdded(model => this.subscribeModel(model));
	}

	private subscribeModel(model: { uri: URI; onDidChangeContent: (listener: () => void) => void; getValue: () => string }) {
		if (!this.isInWorkspace(model.uri)) { return; }
		model.onDidChangeContent(() => {
			try {
				localStorage.setItem(this.prefix + model.uri.toString(), model.getValue());
			} catch (e) {
				console.error('Failed to save file to localStorage', model.uri.toString(), e);
			}
		});
	}

	private subscribeToFileOperations() {
		this.fileService.onDidRunOperation(e => {
			if (e.operation === FileOperation.CREATE && this.isInWorkspace(e.resource)) {
				localStorage.setItem(this.prefix + e.resource.toString(), '');
			} else if (e.operation === FileOperation.MOVE && this.isInWorkspace(e.resource)) {
				// Handle file move/rename: move localStorage entry from old path to new path
				if (e.target) {
					const oldKey = this.prefix + e.resource.toString();
					const newKey = this.prefix + e.target.resource.toString();
					const content = localStorage.getItem(oldKey);
					if (content !== null) {
						localStorage.removeItem(oldKey);
						if (this.isInWorkspace(e.target.resource)) {
							localStorage.setItem(newKey, content);
						}
					}
				}
			} else if (e.operation === FileOperation.DELETE && this.isInWorkspace(e.resource)) {
				const key = this.prefix + e.resource.toString();
				if (localStorage.getItem(key) !== null) {
					localStorage.removeItem(key);
				}
			}
		});
	}
}
