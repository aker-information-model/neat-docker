import fnmatch
import os
import shutil
from subprocess import check_output, CalledProcessError
from pathlib import Path
import tempfile

import logging

from cognite.client import CogniteClient

from cognite.neat.core.workflow.base import BaseWorkflow
from cognite.neat.core.workflow.model import FlowMessage


class Github2GithubNeatWorkflow(BaseWorkflow):
    """Class name must contain 'NeatWorkflow' as suffix!!!"""

    def __init__(self, name: str, client: CogniteClient):
        super().__init__(name, client, [])

        self.base_path = Path(__file__).parent.parent.parent
        self.sheets_path = self.base_path / "sheets"
        self.data_models_path = self.base_path / "data-models"

        # Creating folder to store sheets and data models
        if not self.sheets_path.exists():
            self.sheets_path.mkdir()
        if not self.data_models_path.exists():
            self.data_models_path.mkdir()

        # Creating temporary folder to clone source and output repositories
        # this avoids issues that potential users can create due to messing
        # with source sheets or data models on their local machine
        self.source_repo_path = tempfile.TemporaryDirectory()
        self.output_repo_path = tempfile.TemporaryDirectory()

    def step_clone_github_repos(self, flow_msg: FlowMessage = None):
        clone_repository("source", Path(self.source_repo_path.name))
        clone_repository("output", Path(self.output_repo_path.name))

        return FlowMessage(
            output_text="Successfully cloned 'neat-source' and 'neat-output' repositories from Github",
            next_step_ids=["process_sheets"],
        )

    def step_process_sheets(self, flow_msg: FlowMessage = None):
        logging.info("Processing source sheets...")
        return FlowMessage(
            output_text="Successfully processed source sheets from 'neat-source' repository",
            next_step_ids=["update_graphql_data_model_repository"],
        )

    def step_update_graphql_data_model_repository(self, flow_msg: FlowMessage = None):
        logging.info("Pushing data model(s) to Github")
        copy_files(
            Path(self.source_repo_path.name),
            Path(self.output_repo_path.name),
            extension="xlsx",
        )
        update_repository("output", Path(self.output_repo_path.name))

        return FlowMessage(
            output_text="Successfully updated 'neat-output' repository on Github",
            next_step_ids=["sync_local_copies"],
        )

    def step_sync_local_copies(self, flow_msg: FlowMessage = None):
        logging.info("Sync local copies of sheets and data models")

        copy_files(Path(self.source_repo_path.name), self.sheets_path, extension="xlsx")
        copy_files(
            Path(self.output_repo_path.name), self.sheets_path, extension="graphql"
        )

        return FlowMessage(
            output_text="Successfully synced local copies of sheets and data models",
            next_step_ids=["cleanup"],
        )

    def step_cleanup(self, flow_msg: FlowMessage = None):
        self.source_repo_path.cleanup()
        self.output_repo_path.cleanup()
        logging.info("Cleanup")


def clone_repository(repo_name: str, repo_path: Path):
    logging.info(f"Cloning neat-{repo_name} from Github to {repo_path}")
    try:
        stdout = check_output(
            [
                "git",
                "clone",
                f"git@neat-{repo_name}:aker-information-model/neat-{repo_name}.git",
                str(repo_path.absolute()),
            ]
        ).decode("ascii")
        logging.info(f"aker-information-model/neat-{repo_name} repo status: {stdout}")
    except CalledProcessError as e:
        logging.error(e)
        raise e


def update_repository(repo_name: str, repo_path: Path):
    logging.info(f"Updating neat-{repo_name} on Github")
    try:
        check_output("git add -A", cwd=repo_path, shell=True)
        logging.info(
            f"aker-information-model/neat-{repo_name} repo status: added changes"
        )
    except CalledProcessError as e:
        logging.error(e)
        raise e
    try:
        check_output(
            "git diff-index --quiet HEAD || git commit -m 'update repository'",
            cwd=repo_path,
            shell=True,
        )
        logging.info(
            f"aker-information-model/neat-{repo_name} repo status: committed changes"
        )
    except CalledProcessError as e:
        logging.error(e)
        raise e
    try:
        check_output("git push", cwd=repo_path, shell=True)
        logging.info(
            f"aker-information-model/neat-{repo_name} repo status: pushed changes"
        )
    except CalledProcessError as e:
        logging.error(e)
        raise e


def copy_files(source_folder: Path, destination_folder: Path, extension: str = "xlsx"):
    for filename in os.listdir(source_folder):
        if not fnmatch.fnmatch(filename, f"*.{extension}"):
            continue
        shutil.copyfile(source_folder / filename, destination_folder / filename)
        logging.info(f"File {filename} copied to {destination_folder}")
