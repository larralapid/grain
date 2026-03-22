# Project Board

Grain uses a [GitHub Project](https://github.com/users/larralapid/projects) board to organize and visualize all issues.

## Setup

Follow these steps to connect the project board to the repository automation.

### 1. Create the project

1. Go to **github.com → Your profile → Projects → New project**.
2. Choose the **Board** layout (or **Table** — you can switch later).
3. Name the project **Grain** and create it.
4. Copy the project URL (e.g. `https://github.com/users/larralapid/projects/1`).

### 2. Add recommended views

| View | Layout | Group by | Filter |
|------|--------|----------|--------|
| **Kanban** | Board | Status | — |
| **By Priority** | Table | Priority | — |
| **By Area** | Table | Area label | — |
| **Backlog** | Table | — | `status:Backlog` |

### 3. Add recommended custom fields

| Field | Type | Values |
|-------|------|--------|
| Priority | Single select | `high`, `medium`, `low` |
| Area | Single select | `scanning`, `analytics`, `export`, `integrations`, `design` |
| Sprint | Iteration | 2-week iterations |

### 4. Configure repository automation

The workflow at `.github/workflows/add-to-project.yml` automatically adds every new issue to the project board. It needs two things:

1. **Repository variable** `PROJECT_URL` — set this to the project URL from step 1.
   - Go to **Settings → Secrets and variables → Actions → Variables → New repository variable**.
   - Name: `PROJECT_URL`, Value: your project URL.
2. **Repository secret** `ADD_TO_PROJECT_PAT` — a personal access token with the `project` scope.
   - Go to **Settings → Developer settings → Personal access tokens → Fine-grained tokens**.
   - Create a token with **Repository access → grain** and **Account permissions → Projects → Read and write**.
   - Add it as a repository secret at **Settings → Secrets and variables → Actions → New repository secret**.

### 5. Add existing issues

The automation only runs on new issues. To add the existing issues to the project board, open the project and use **+ Add item → Add item from repository → grain** to bulk-add them.

## Workflow

1. New issues are automatically added to the project board with **Backlog** status.
2. During planning, move issues to **Ready** or **In Progress**.
3. Use the **By Priority** and **By Area** views to plan sprints.
4. Close issues when done — they move to **Done** automatically.
