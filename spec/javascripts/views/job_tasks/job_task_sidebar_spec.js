describe("chorus.views.JobTaskSidebar", function () {
    beforeEach(function () {
        this.job = backboneFixtures.job();
        this.task = this.job.tasks().at(0);
        this.view = new chorus.views.JobTaskSidebar({model: this.task});
        this.modalSpy = stubModals();
        this.view.render();
    });

    it("displays the job tasks name", function () {
        expect(this.view.$(".name")).toContainText(this.task.get("name"));
    });

    describe("clicking 'Delete Job Task'", function () {
        itBehavesLike.aDialogLauncher("a.delete_job_task", chorus.alerts.JobTaskDelete);
    });

    describe("clicking 'Edit Job Task'", function () {
        context("when a RunWorkFlow task is selected", function () {
            beforeEach(function () {
                this.task.set('action', 'run_work_flow');
            });
            itBehavesLike.aDialogLauncher("a.edit_job_task", chorus.dialogs.ConfigureWorkFlowTask);
        });

        context("when an Import task is selected", function () {
            beforeEach(function () {
                this.task.set('action', 'import_source_data');
            });

            itBehavesLike.aDialogLauncher("a.edit_job_task", chorus.dialogs.ConfigureImportSourceDataTask);
        });
    });
});