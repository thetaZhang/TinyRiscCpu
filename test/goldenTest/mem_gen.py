#!/usr/bin/env python3
import argparse
import os

def convert_to_byte_format(input_file, output_file, second_file=None):
    try:
        # Process the first input file
        with open(input_file, 'r') as f:
            lines = [line.strip() for line in f if line.strip() and not line.startswith('//')]
        
        # Open output file and write the first part as memory bytes
        with open(output_file, 'w') as f:
            # Output the first part of memory data as bytes
            f.write(".data\n")
            for i in range(0, len(lines), 4):
                if i+3 < len(lines):
                    bytes_group = [f"0x{lines[i]}", f"0x{lines[i+1]}", 
                                  f"0x{lines[i+2]}", f"0x{lines[i+3]}"]
                    f.write(f".byte {', '.join(bytes_group)}  # address {i//4}\n")
            
            # If a second file is provided, append its contents directly
            if second_file and os.path.exists(second_file):
                f.write("\n.text\n")
                with open(second_file, 'r') as second_f:
                    # Read all lines from the second file
                    second_content = second_f.read()
                    # Append the content directly to the output file
                    f.write(second_content)
                print(f"Appended second file: {second_file}")
        
        print(f"Conversion completed: {input_file} -> {output_file}")
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    # Create argument parser
    parser = argparse.ArgumentParser(description='Convert memory byte files to assembly format')
    
    # Add arguments
    parser.add_argument('-i', '--input', required=True, help='Main input file path')
    parser.add_argument('-o', '--output', required=True, help='Output file path')
    parser.add_argument('-s', '--second', help='Second file to append directly (optional)')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Check if main input file exists
    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' does not exist")
        return
    
    # Check if second input file exists (if provided)
    if args.second and not os.path.exists(args.second):
        print(f"Warning: Second file '{args.second}' does not exist, will only process main input file")
    
    # Check if output directory exists
    output_dir = os.path.dirname(args.output)
    if output_dir and not os.path.exists(output_dir):
        try:
            os.makedirs(output_dir)
            print(f"Created output directory: {output_dir}")
        except Exception as e:
            print(f"Unable to create output directory: {e}")
            return
    
    # Execute conversion
    convert_to_byte_format(args.input, args.output, args.second)

if __name__ == "__main__":
    main()