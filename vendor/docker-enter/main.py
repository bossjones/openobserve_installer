#!/usr/bin/env python3

from dataclasses import dataclass
from subprocess import Popen, PIPE, run
from typing import List, Optional, Callable, TypeVar, Any
import inquirer
from typing_extensions import TypeAlias

T = TypeVar('T')
ErrorCallback: TypeAlias = Callable[[Exception], Any]
SuccessCallback: TypeAlias = Callable[[], Any]

@dataclass
class ContainerChoice:
    """Represents a Docker container choice for selection.

    Attributes:
        value: The container ID
        name: The display name combining container name and ID
    """
    value: str
    name: str

def get_containers() -> List[ContainerChoice]:
    """Fetch running Docker containers and format them as choices.

    Returns:
        List[ContainerChoice]: List of container choices with their IDs and names.

    Raises:
        subprocess.CalledProcessError: If the docker command fails
    """
    result = run(['docker', 'ps'], capture_output=True, text=True, check=True)
    lines = result.stdout.strip().split('\n')[1:]  # Skip header row

    choices = []
    for line in lines:
        parts = [part for part in line.split('   ') if part.strip()]
        if len(parts) >= 7:
            container_id = parts[0].strip()
            container_name = parts[6].strip()
            choices.append(ContainerChoice(
                value=container_id,
                name=f"{container_name} - {container_id}"
            ))

    return choices

def get_container_selection(choices: List[ContainerChoice]) -> Optional[str]:
    """Prompt user to select a container from the list.

    Args:
        choices: List of container choices to present to user

    Returns:
        Optional[str]: Selected container ID or None if selection was cancelled
    """
    questions = [
        inquirer.List('container_id',
                     message="Select a container",
                     choices=[(c.name, c.value) for c in choices])
    ]

    answers = inquirer.prompt(questions)
    return answers['container_id'] if answers else None

def spawn_container(container_id: str) -> None:
    """Spawn an interactive bash session in the selected container.

    Args:
        container_id: The ID of the container to connect to

    Raises:
        subprocess.CalledProcessError: If the docker exec command fails
    """
    process = Popen(['docker', 'exec', '-it', container_id, 'bash'])
    process.communicate()

def main(error_callback: ErrorCallback, success_callback: SuccessCallback) -> None:
    """Main function to handle container selection and connection.

    Args:
        error_callback: Callback function to handle errors
        success_callback: Callback function to handle success
    """
    try:
        choices = get_containers()
        if not choices:
            error_callback(Exception("No running containers found"))
            return

        container_id = get_container_selection(choices)
        if not container_id:
            error_callback(Exception("No container selected"))
            return

        spawn_container(container_id)
        success_callback()
    except Exception as e:
        error_callback(e)

if __name__ == '__main__':
    main(lambda e: print(f"Error: {e}"), lambda: None)
