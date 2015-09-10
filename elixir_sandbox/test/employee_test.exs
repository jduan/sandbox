defmodule EmployeeTest do
  use ExUnit.Case

  test "print" do
    IO.puts System.cwd()
    IO.inspect(Employee.print("./test/employee_data.csv"))
  end
end
