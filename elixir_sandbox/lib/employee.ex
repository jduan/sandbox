# Org Chart

# Input: CSV file

# name, start date, boss
# Employee A, 2000, Employee B
# Employee B, 2000, Employee G
# Employee G, 1990,
# Employee C, 2001, Employee A
# Employee D, 2000, Employee G
# Employee E, 2000, Employee B
# Employee F, 2000, Employee E
#
# Write a program that reads such a CSV file and prints the employee hierarchy:
#
# Output:
#
# Employee G (1990)
# |
# |- Employee B (2000)
# |  |
# |  |- Employee A (2000)
# |  |  |
# |  |  |- Employee C (2001)
# |  |
# |  |- Employee E (2000)
# |     |
# |     |- Employee F (2000)
# |
# |- Employee D (2000)


defmodule Employee do
  def print(csv_file) do
    employee_dict = csv_file
    |> File.stream!
    |> Stream.map(fn line -> String.rstrip(line) end)
    |> Enum.reduce(HashDict.new, &parse_employees/2)

    {dict, ceo} = csv_file
    |> File.stream!
    |> Stream.map(fn line -> String.rstrip(line) end)
    |> Enum.reduce({employee_dict, nil}, &parse_bosses/2)

    print_org(dict, ceo, 0)
  end

  defp parse_employees(line, dict) do
    [employee_name, start_date, _boss_name] = String.split(line, ",")
    Dict.put(dict, employee_name, {start_date, []})
  end

  defp parse_bosses(line, {dict, ceo}) do
    [employee_name, start_date, boss_name] = String.split(line, ",")
    if boss_name == "" do
      {dict, employee_name}
    else
      {start_date, reports} = Dict.get(dict, boss_name)
      {Dict.put(dict, boss_name, {start_date, [employee_name | reports]}), ceo}
    end
  end

  defp print_org(dict, employee_name, indent) do
    {start_date, reports} = Dict.get(dict, employee_name)
    IO.puts("#{String.duplicate(" ", indent * 2)} #{employee_name} (#{start_date})")
    reports
    |> Enum.each(fn report -> print_org(dict, report, indent + 1) end)
  end
end
