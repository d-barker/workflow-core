using System;
using System.Collections.Generic;
using FluentAssertions;
using WorkflowCore.Interface;
using WorkflowCore.Models;
using WorkflowCore.Testing;
using Xunit;

namespace WorkflowCore.IntegrationTests.Scenarios
{
    public class DynamicDataIOScenario : WorkflowTest<DynamicDataIOScenario.DataIOWorkflow, DynamicDataIOScenario.MyDataClass>
    {
        public class AddNumbers : StepBody
        {
            public int Input1 { get; set; }
            public int Input2 { get; set; }
            public int Output { get; set; }

            public override ExecutionResult Run(IStepExecutionContext context)
            {
                Output = (Input1 + Input2);
                return ExecutionResult.Next();
            }
        }

        public class MyDataClass
        {
            public int Value1 { get; set; } = 4;
            public int Value2 { get; set; } = 5;
            public int Result { get; set; } = 0;
        }

        public class DataIOWorkflow : IWorkflow<DynamicDataIOScenario.MyDataClass>
        {
            public string Id => "DynamicDataIOWorkflow";
            public int Version => 1;
            public void Build(IWorkflowBuilder<DynamicDataIOScenario.MyDataClass> builder)
            {
                builder
                    .StartWith<AddNumbers>()
                        .Input(step => step.Input1, data => data.Value1)
                        .Input(step => step.Input2, data => data.Value2)
                        .Output((step, data) => data.Result = step.Output);
            }
        }

        public DynamicDataIOScenario()
        {
            Setup();
        }

        [Fact]
        public void Scenario()
        {
            var data = new DynamicDataIOScenario.MyDataClass() { Value1 = 2, Value2 = 3 };
            //data.SetValue("Test", 33);
            var workflowId = StartWorkflow(data);
            WaitForWorkflowToComplete(workflowId, TimeSpan.FromSeconds(30));

            GetStatus(workflowId).Should().Be(WorkflowStatus.Complete);
            UnhandledStepErrors.Count.Should().Be(0);
            GetData(workflowId).Result.Should().Be(5);
        }
    }
}
